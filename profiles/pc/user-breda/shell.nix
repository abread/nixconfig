{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    envExtra = ''
      if [[ -z $DISPLAY ]] && [[ "a$XDG_SESSION_TYPE" = "atty" ]] && [[ $(tty) = /dev/tty1 ]]; then
          export PATH="$HOME/.local/waybin:$PATH"
          export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share" # we put fonts there and flatpak struggles
          export _JAVA_AWT_WM_NONREPARENTING=1
          export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export QT_QPA_PLATFORM="wayland;xcb"
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export GDK_BACKEND=wayland,x11
          export SDL_VIDEODRIVER=wayland
          export CLUTTER_BACKEND=wayland
          export NIXOS_OZONE_WL=1 # wayland in chrome/chromium/electron/...
          export MOZ_ENABLE_WAYLAND=1
          export MOZ_WEBRENDER=1
          export MOZ_ACCELERATED=1
          export LIBVA_DRIVER_NAME="radeonsi"
          export VDPAU_DRIVER="radeonsi"
          export AMD_VULKAN_ICD=RADV
          export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"

          eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
          export SSH_AUTH_SOCK

          # let subshells use new vars (after switching home-manager generation)
          unset __HM_ZSH_SESS_VARS_SOURCED

          exec systemd-cat --identifier=sway sway
      fi
    '';

    sessionVariables = {
      GTK_THEME = "Adwaita:dark";
      TERMINAL = "alacritty -e";
      EDITOR = "nvim";
      BROWSER = "chromium";
      PATH = "$HOME/.krew/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH";
      DICPATH = "~/.local/share/hunspell:$DICPATH";
      FZF_DEFAULT_COMMAND = "${pkgs.ripgrep}/bin/rg --files --no-ignore --hidden --follow --glob '!.git/*'";
      ELECTRON_TRASH = "gio";
      SCCACHE_DIR = "/var/cache/sccache";
      SCCACHE_MAX_FRAME_LENGTH = "104857600";
      VAGRANT_DEFAULT_PROVIDER = "libvirt";
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      PROTOC = "/run/current-system/sw/bin/protoc";
    };

    initExtraBeforeCompInit = ''
      setopt extendedglob nomatch
      setopt no_beep
      setopt interactive_comments

      # Case-insensitive completions
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Show what I selected during tab completions
      zstyle ':completion:*' menu select

      # can't really be an alias, so let's define a function instead
      function ldapsearch() {
          _binddn="uid=ist189409,ou=People,dc=ist,dc=utl,dc=pt" # spellchecker:disable-line
          /run/current-system/sw/bin/ldapsearch -D "$_binddn" -y <(pass show tecnico.ulisboa.pt/ist189409 | tr -d '\n') "$@"
      }
    '';

    initExtra = ''
      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
    '';

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableVteIntegration = true;

    autocd = true;

    shellAliases = {
      open = "xdg-open";
      ls = "eza";
      l = "eza -l";
      ll = "eza -l";
      la = "eza -la";
      ip = "ip --color=auto";
      youtube-dl = "yt-dlp";
      grep = "rg";
      restic = "restic -r rclone:b2-backups-tightpants:backups-tightpants --password-command 'pass show restic-backups/tightpants'";
    };
    history = {
      save = 20000000;
      size = 1000000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = "$terminfo[kcuu1]";
      searchDownKey = "$terminfo[kcud1]";
    };
    defaultKeymap = "emacs";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
