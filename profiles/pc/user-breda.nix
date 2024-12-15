{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.breda = import ./user-breda/default.nix;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
  ];

  users.users.breda = {
    isNormalUser = true;
    uid = 1001;
    shell = pkgs.zsh;
    group = "users";
    extraGroups = [
      # Enable ‘sudo’ for the user
      "wheel"

      "input"
      "video"
      "render"
      "networkmanager"
      "dialout"
      "adbusers"
    ];
    hashedPassword = inputs.hidden.userHashedPasswords.${config.networking.hostName}.breda;
  };

  programs.zsh.enable = true; # generate /etc/zprofile

  # TODO: move to home-manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      mako
      alacritty
      #foot # TODO: switch?
      bemenu
      waybar
      wf-recorder
      networkmanagerapplet
      grim
      slurp
      swappy
      flameshot
      j4-dmenu-desktop
      vorbis-tools
      soteria # polkit auth agent
      pulseaudio # pactl
      xdg-utils # xdg-open
      glib # gio
    ];
  };
  programs.nm-applet.enable = true;
  programs.browserpass.enable = true;
  programs.gnupg.agent.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      fira-code
      fira-math
      fira
      ibm-plex
      source-code-pro
      source-sans
      carlito
      caladea
      liberation_ttf
      vistafonts
      font-awesome
      aileron
    ];

    fontconfig = {
      allowBitmaps = false;
      defaultFonts = {
        serif = [
          "IBM Plex Serif"
          "Noto Serif"
          "Noto Sans CJK JP"
        ];
        sansSerif = [
          "IBM Plex Sans"
          "Noto Sans CJK JP"
        ];
        monospace = [
          "Fira Code"
          "Noto Sans Mono CJK JP"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  environment.variables.GDK_BACKEND = "wayland";
  environment.variables.MOZ_ENABLE_WAYLAND = "1";
  systemd.user.services.xdg-desktop-portal.wantedBy = [ "sway-session.target" ];
  systemd.user.services.xdg-desktop-portal-wlr.wantedBy = [ "sway-session.target" ];
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = [ "sway-session.target" ];
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    #pkgs.xdg-desktop-portal-wlr # try leaving it off, should be added by xdg.portal.wlr.enable
  ];
  # Make xdg-desktop-portal aware of each portals (should be upstreamed)
  # NixOS 24.05: og var disappeared ???
  #systemd.user.services.xdg-desktop-portal.environment = {
  #  XDG_DESKTOP_PORTAL_DIR = config.environment.variables.XDG_DESKTOP_PORTAL_DIR;
  #};

  xdg.portal.wlr.settings = {
    screencast = {
      # TODO: inhibit notifications, see mako modes
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
  };
  xdg.portal.config = {
    common = {
      default = [ "*" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    sway = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    user = "breda";
    dataDir = "/home/breda";
    configDir = "/home/breda/.config/syncthing";
  };

  # Use Ozone Wayland in "Chrome and several electron apps"
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.pathsToLink = [
    "/libexec"
    "/share/zsh"
    "/share/backgrounds/sway"
  ];
}
