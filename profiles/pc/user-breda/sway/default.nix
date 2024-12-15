{ ... }:
{
  imports = [
    ./kanshi.nix
  ];

  #  wayland.windowManager.sway = let
  #        terminal = "${pkgs.foot}/bin/foot";
  #        bemenu_opts = "-i -f --fn 'Fira Code 12' --nb '#100F10' --nf '#E0E6F0' --fb '#000000' --ff '#FFFFFF' --hb '#2A40B8' --hf '#FFFFFF' --scf '#34CFFF' -p '' -w -l 10'";
  #        modifier = "Mod4";
  #    in {
  #    enable = true;
  #    config = rec {
  #      inherit modifier terminal;
  #
  #      bars = [
  #        {
  #          command = "${pkgs.waybar}/bin/waybar";
  #        }
  #      ];
  #
  #      colors = {
  #        # based on modus-vivendi
  #
  #        background = "#000000";
  #        focused = {
  #          border = "#2A40B8";
  #          background = "#2A40B8";
  #          text = "#FFFFFF";
  #          indicator = "#2A40B8";
  #          childBorder = "#2A40B8";
  #        };
  #        focusedInactive = {
  #          border = "#0F0E39";
  #          background = "#0F0E39";
  #          text = "#E0E6F0";
  #          indicator = "#0F0E39";
  #          childBorder = "#0F0E39";
  #        };
  #        unfocused = {
  #          border = "#3A303B";
  #          background = "#110B11";
  #          text = "#E0E6F0";
  #          indicator = "#3A303B";
  #          childBorder = "#3A303B";
  #        };
  #        urgent = {
  #          border = "#8F0040";
  #          background = "#A4202A";
  #          text = "#FFFFFF";
  #          indicator = "#8F0040";
  #          childBorder = "#8F0040";
  #        };
  #        placeholder = {
  #          border = "#6F4A00";
  #          background = "#604200";
  #          text = "#BEBEBE";
  #          indicator = "#6F4A00";
  #          childBorder = "#6F4A00";
  #        };
  #      };
  #
  #      floating = {
  #        criteria = [
  #          {
  #            title = "Firefox - Sharing Indicator";
  #          }
  #          {
  #            title = "(Save|Open) (File|Folder)(s)?";
  #          }
  #        ];
  #      };
  #
  #      fonts = {
  #        names = ["IBM Plex Sans"];
  #        size = 12.0;
  #      };
  #
  #      input = {
  #        "2:14:ETPS/2_Elantech_Touchpad" = {
  #          dwt = "disabled";
  #          tap = "enabled";
  #          natural_scroll = "enabled";
  #          middle_emulation = "enabled";
  #          scroll_method = "two_finger";
  #        };
  #        "type:keyboard" = {
  #          xkb_layout = "pt";
  #          xkb_options = "caps:swapescape";
  #          repeat_delay = "300";
  #          repeat_rate = "50";
  #        };
  #      };
  #
  #      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu='${pkgs.bemenu}/bin/bemenu ${bemenu_opts}' --term='${terminal}' --no-generic";
  #
  #      keybindings = lib.mkOptionDefault {
  #        "${modifier}+Return" = "exec ${pkgs.systemd}/bin/systemd-cat --identifier=swayterm ~/.local/bin/sway-shell.sh";
  #        "${modifier}+Shift+d" = "exec ${pkgs.bemenu}/bin/bemenu-run ${bemenu_opts} | xargs swaymsg exec --";
  #
  #        "${modifier}+0" = "workspace 10";
  #        "${modifier}+Shift+0" = "move container to workspace 10";
  #
  #        "Shift+${modifier}+v" = "splith";
  #
  #        # disable scratchpad keybindings
  #        "${modifier}+Shift+minus" = "exec true";
  #        "${modifier}+minus" = "exec true";
  #
  #        "${modifier}+Shift+c" = "exec true";
  #        "${modifier}+Shift+r" = "reload";
  #
  #        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
  #        "XF86Tools" = "exec pkill -USR1 swayidle";
  #        "Shift+Print" = "exec 'grim -g \"$(slurp)\" - | swappy -f -'";
  #        "Print" = "exec 'grim -g \"$(slurp)\" - | wl-copy -t image/png'";
  #        "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
  #      };
  #
  #    output = {
  #      e-DP1 = {
  #        pos = "0 0";
  #        resolution = "1920x1080";
  #        scale = "1";
  #        background = "#181A20 solid_color";
  #        adaptive_sync = "on";
  #        subpixel = "rgb";
  #      };
  #    };
  #
  #    startup = [
  #      #{ command = "systemd-cat --identifier=sway-session-helper /home/breda/.config/sway/session.sh -E XCURSOR_SIZE -E XDG_SEAT -E XDG_VTNR -E XDG_SESSION_CLASS -E XDG_SESSION_ID --with-cleanup"; }
  #
  #      # TODO: package
  #      { command = "systemd-cat --identifier=battery-popup ~/.local/bin/battery-popup.sh -L 20 -m 'CHARGE MEEEEEE!!!' -n"; }
  #
  #      # TODO: change to services.mako
  #      { command = "systemd-cat --identifier=mako mako"; }
  #    ];
  #
  #    window = {
  #      border = 0;
  #      commands = [
  #        {
  #          criteria.app_id = "Alacritty";
  #          command = "border normal";
  #        }
  #        {
  #          criteria.app_id = "foot";
  #          command = "border normal";
  #        }
  #        {
  #          criteria = { class = "vlc"; window_type = "normal"; };
  #          command = "border normal";
  #        }
  #        {
  #          criteria = { app_id = "eagle"; window_type = "normal"; };
  #          command = "border normal";
  #        }
  #        {
  #          criteria.class = "processing-app-Base";
  #          command = "border normal";
  #        }
  #        {
  #          criteria.title = "Firefox - Sharing Indicator";
  #          command = "border pixel 3";
  #        }
  #        {
  #          criteria.title = "Firefox - Sharing Indicator";
  #          command = "move absolute position 1840 990"; # TODO: do it more reliably maybe?
  #        }
  #      ];
  #    };
  #
  #    workspaceAutoBackAndForth = true;
  #
  #    };
  ##    extraSessionCommands = ''
  ##      export _JAVA_AWT_WM_NONREPARENTING=1
  ##      export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
  ##      export QT_AUTO_SCREEN_SCALE_FACTOR=1
  ##      export QT_QPA_PLATFORM=wayland
  ##      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  ##      export GDK_BACKEND=wayland
  ##      export NIXOS_OZONE_WL=1 # wayland in chrome/chromium/electron/...
  ##      export MOZ_ENABLE_WAYLAND=1
  ##      export MOZ_WEBRENDER=1
  ##      export MOZ_ACCELERATED=1
  ##    '';
  #
  #    extraConfig = ''
  #      bindsym --locked {
  #        XF86AudioMute exec "pactl set-sink-mute @DEFAULT_SINK@ toggle"
  #        XF86AudioLowerVolume exec "pactl set-sink-volume @DEFAULT_SINK@ -5%"
  #        XF86AudioRaiseVolume exec "pactl set-sink-volume @DEFAULT_SINK@ +5%"
  #        Shift+XF86AudioLowerVolume exec "pactl set-sink-volume @DEFAULT_SINK@ -1%"
  #        Shift+XF86AudioRaiseVolume exec "pactl set-sink-volume @DEFAULT_SINK@ +1%"
  #
  #        ${modifier}+P exec 'playerctl play-pause'
  #        ${modifier}+N exec 'playerctl next'
  #
  #        # headphones use this
  #        XF86AudioPlay exec 'playerctl play'
  #        XF86AudioPause exec 'playerctl pause'
  #        XF86AudioNext exec 'playerctl next'
  #        XF86AudioPrev exec 'playerctl previous'
  #
  #        Shift+XF86MonBrightnessUp exec "xbacklight -ctrl amdgpu_bl0 -inc 1 -fps 60"
  #        Shift+XF86MonBrightnessDown exec "xbacklight -ctrl amdgpu_bl0 -dec 1 -fps 60"
  #        XF86MonBrightnessUp exec "xbacklight -ctrl amdgpu_bl0 -inc 5 -fps 60"
  #        XF86MonBrightnessDown exec "xbacklight -ctrl amdgpu_bl0 -dec 5 -fps 60"
  #      }
  #
  #    '';
  #
  #    swaynag.enable = true;
  #    systemdIntegration = true;
  #    wrapperFeatures.gtk = true;
  #  };

  #  programs.swaylock = {
  #    enable = true;
  #    settings = {
  #      color = "181A20";
  #      ignore-empty-password = true;
  #      show-failed-attempts = true;
  #      font = "IBM Plex Sans";
  #    };
  #  };
  #
  #  services.swayidle = {
  #    enable = true;
  #    timeouts = [
  #      {
  #        timeout = 600;
  #        command = "swaymsg 'output * power off";
  #        resumeCommand = "swaymsg 'output * power on'";
  #      }
  #      { timeout = 610; command = "loginctl lock-session"; }
  #    ];
  #    events = [
  #      { event = "before-sleep"; command = "loginctl lock-session"; }
  #      { event = "lock"; command = "swaylock -f"; }
  #    ];
  #  };

  #  services.mako = {
  #    enable = true;
  #    defaultTimeout = 120000;
  #    font = "IBM Plex Sans 12";
  #
  #    extraConfig = ''
  #      on-button-left=dismiss
  #      on-button-middle=invoke-default-action
  #      on-button-right=dismiss-group
  #
  #      [app-name="discord"]
  #      group-by=summary
  #      default-timeout=10000
  #
  #      [app-name="Spotify"]
  #      default-timeout=1000
  #
  #      [app-name="Mattermost"]
  #      group-by=summary
  #      default-timeout=1000
  #    '';
  #  };
}
