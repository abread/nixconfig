{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.breda = import ./user-breda-home.nix;
    }
  ];

  users.users.breda = {
    isNormalUser = true;
    uid = 1001;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "video" "render" "networkmanager" "dialout" "adbusers"]; # Enable ‘sudo’ for the user.
    hashedPassword = inputs.hidden.userHashedPasswords.${config.networking.hostname}.breda;
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
      polkit_gnome
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
      fira
      ibm-plex
      source-code-pro
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
        serif = ["IBM Plex Serif" "Noto Serif" "Noto Sans CJK JP"];
        sansSerif = ["IBM Plex Sans" "Noto Sans CJK JP"];
        monospace = ["Fira Code" "Noto Sans Mono CJK JP"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
