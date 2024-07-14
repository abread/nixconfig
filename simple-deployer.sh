#!/usr/bin/env bash
set -e

{ command -v dialog && command -v nom && command -v jq && command -v tmux; } >/dev/null || nix-shell -p nix-output-monitor -p jq -p dialog -p tmux --run "$0"

if [[ $# -eq 0 ]]; then
	# Grab list of hosts, selecting only those with simple-deployer enabled.
	host_metadata="$(mktemp simple-deployer.XXXXXXXXXX)"
	trap "rm '${host_metadata}'" EXIT
	nix eval --json .\#nixosConfigurations --apply 'f: builtins.mapAttrs (h: v: v.config.modules.simple-deployer) f' | jq -c '. | map_values(select(.enable))' > "$host_metadata"
	
	# Ask the user which ones should be updated
	readarray -t checklist_entries < <(jq -r 'to_entries | map(.key + "\n" + .value.targetHost + "\n" + if .value.defaultSelect then "on" else "off" end) | .[]' "$host_metadata")
	chosen_hosts="$(dialog --stdout --checklist 'Select hosts to (re-)build:' 0 0 0 "${checklist_entries[@]}")"
	[[ -z "$chosen_hosts" ]] && echo "No hosts chosen, nothing to do." && exit 0
	
	# Filter host metadata based on user choices
	chosen_hosts_filter="{ $(echo -n "$chosen_hosts" | sed -E 's/^/"/' | sed -E 's/ /": 1,"/g' | sed -E 's/$/": 1/') }"
	jq -c "with_entries(select(.key | in(${chosen_hosts_filter})))" "$host_metadata" > "${host_metadata}.new"
	mv "${host_metadata}.new" "$host_metadata"

	readarray -t build_configs < <(jq -r 'keys | map(".#nixosConfigurations." + . + ".config.system.build.toplevel") | .[]' "$host_metadata")
	ionice nice nom build "${build_configs[@]}"

	echo
	read -r -p "Press any key to continue..."

	# Open tmux with individual rebuild options for each host
	for host_data in $(jq -c 'to_entries | .[]' "$host_metadata"); do
		hostname="$(echo "$host_data" | jq -r '.key')"
		targetHost="$(echo "$host_data" | jq -r '.value.targetHost')"
		useRemoteSudo="$(echo "$host_data" | jq -r '.value.useRemoteSudo')"
		cmd=("$0" "$hostname" "$targetHost" "$useRemoteSudo")
		if [[ -n "$tmux_sock_name" ]]; then
			tmux -L"$tmux_sock_name" new-window "${cmd[@]}"
		else
			tmux_sock_name="rebuild.${RANDOM}"
			tmux -L"$tmux_sock_name" new-session -d "${cmd[@]}"
		fi

		tmux -L"$tmux_sock_name" rename-window "$hostname"
	done

	exec tmux -L"$tmux_sock_name" attach
fi

hostname="$1"
target="$2"
[[ "$3" == true ]] && useRemoteSudo="--use-remote-sudo"

reboot_cmd="echo 'I don't know how to reboot this host'"
if [[ "$(hostname)" == "$hostname" ]]; then
	reboot_cmd="echo 'I refuse to reboot the current host.'"
	targetHost=()
else
	reboot_cmd=(ssh "$target" reboot)
	targetHost=(--target-host "$target")
fi
unset target

rebuild() {
	op="$1"
	nixos-rebuild "$op" --flake ".#${hostname}" "${targetHost[@]}" "$useRemoteSudo"
}

# show result of dry activation
echo "This is the result of switching to the new configuration in ${hostname}:"
rebuild dry-activate
echo
read -r -p "Press any key to continue..."

while true; do
	action="$(dialog --stdout --menu "Choose what to do with ${hostname}:" 0 0 0 "inspect" "Inspect the changes caused by the new configuration (again)" "boot" "Add new configuration to top of boot order" "switch" "Switch to the new configuration immediately" "exit" "Nothing, just exit")"

	case "$action" in
		inspect)
			echo "This is the result of switching to the new configuration in ${hostname}:"
			rebuild dry-activate
			echo
			read -r -p "Press any key to continue..."
			;;
		boot)
			echo "${hostname}: Adding new configuration to boot order"
			rebuild boot

			if [[ "$(hostname)" != "$hostname" ]]; then
				echo
				read -r -p "Press any key to continue..."
				if dialog --yesno "Do you want to reboot ${hostname}?" 0 0; then
					"${reboot_cmd[@]}"
				fi
			else
				echo "Don't forget to reboot!"
			fi

			echo
			read -r -p "Done. Press any key to exit"
			exit 0
			;;
		switch)
			echo "${hostname}: Adding new configuration to boot order"
			rebuild switch

			echo
			read -r -p "Done. Press any key to exit"
			exit 0
			;;
		exit)
			if dialog --yesno "Are you sure you want to exit?" 0 0; then
				exit 0
			fi
			;;
		*)
			echo
			echo "Unknown command. Aborting"
			echo
			read -r -p "Press any key to exit"
			exit 1
	esac
done
