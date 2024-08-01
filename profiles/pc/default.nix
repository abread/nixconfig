{
  inputs,
  profiles,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # working (and fast) command-not-found with flakes
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite

    profiles.core
    profiles.shell

    ./unstable-pkgs-nix-cmd.nix
    ./flatpak.nix
    ./devtools.nix
    ./network.nix
    ./virt.nix
    ./user-breda
  ];

  environment.systemPackages = with pkgs; [
    imagemagick
    nix-output-monitor

    usbutils
    pciutils
    nvme-cli

    (chromium.override {enableWideVine = true;})
    thunderbird
    transmission-gtk
    gnome.seahorse
    libreoffice
    ultrastardx
    musescore
    steam
    wdisplays
    pavucontrol

    plugin-autenticacao-gov
    pass-wayland
    dos2unix
    wget
    zathura
    texlive.combined.scheme-full
    hyfetch
    pdfpc
    rlwrap
    sl
    pv
    fzf
    bat
    nmap
    patchelf
    inotify-tools
    dmidecode
    ipcalc
    libsecret
    eva
    pinentry-gnome3
    file
    playerctl
    sshuttle
    sshfs
    xorg.xauth # X11Forwarding
    waypipe
    unstable.yt-dlp
    ffmpeg_5-full
    openldap
    powertop
    hunspell
    hunspellDicts.en_US-large
    wl-clipboard
    timewarrior

    bluez5-experimental # bluetooth-autoconnect
    libnotify # notify-send

    # required for themes
    gtk3
    gnome3.adwaita-icon-theme

    mpv
    alass # subtitle sync

    restic
    rclone

    atool
    zip
    unzip
    unrar
    p7zip
    cabextract
    dpkg

    # can't remember why I have these
    xorg.libX11
    xorg.libXext
  ];

  environment.pathsToLink = ["/share/hunspell" "/share/myspell"];
  environment.variables.DICPATH = "/run/current-system/sw/share/hunspell";

  programs.chromium.enable = true; # this only enables chromium policies, not chromium itself
  programs.chromium.extraOpts.AuthServerAllowlist = "id.tecnico.ulisboa.pt";

  programs.firefox = {
    enable = true;
    preferences."network.negotiate-auth.trusted-uris" = "id.tecnico.ulisboa.pt";
  };

  # for now PCs can be build hosts
  nix.extraOptions = ''
    secret-key-files = /nix/secrets/nix-build-priv-key
  '';
  modules.herdnix = {
    deploymentUser = "breda";
    createSudoRules = false;
  };

  boot.loader.efi.canTouchEfiVariables = true; # ?

  # enable automatic-timezoned, which needs time.timeZone to be unset
  time.timeZone = lib.mkForce null;
  services.automatic-timezoned.enable = true;

  # TODO: move out to laptop-specific thing
  services.udev.extraRules = ''
    # the battery shall not get critically low
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-3]", RUN+="${pkgs.systemd}/bin/systemctl hibernate --check-inhibitors=no"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[3-5]", RUN+="${pkgs.systemd}/bin/systemctl suspend --check-inhibitors=no"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[5-10]", RUN+="${pkgs.systemd}/bin/systemctl suspend --check-inhibitors=no"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[11-15]", RUN+="${pkgs.systemd}/bin/systemctl suspend --check-inhibitors=no"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[16-20]", RUN+="${pkgs.systemd}/bin/systemctl suspend"
  '';

  # Logitech Unifying
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  services.printing.enable = true;
  services.printing.drivers = [pkgs.brgenml1lpr pkgs.brgenml1cupswrapper pkgs.hplip];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.fwupd.enable = true;

  security.krb5 = {
    enable = true;
    settings = {
      libdefaults = {
        default_realm = "IST.UTL.PT"; # spellchecker:disable-line
        forwardable = true;
        proxiable = true;
      };
      # spellchecker:off
      realms."IST.UTL.PT" = {
        default_domain = "ist.utl.pt";
      };
      domain_realm = {
        ".ist.utl.pt" = "IST.UTL.PT";
        "ist.utl.pt" = "IST.UTL.PT";
        ".tecnico.ulisboa.pt" = "IST.UTL.PT";
        "tecnico.ulisboa.pt" = "IST.UTL.PT";
      };
      # spellchecker:on
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      libvdpau
      vaapiVdpau
      libvdpau-va-gl
      rocmPackages.clr
      amdvlk
    ];

    driSupport = true;
    driSupport32Bit = true;
  };

  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  boot.supportedFilesystems.ntfs = true;

  hardware.wirelessRegulatoryDatabase = true;
  hardware.acpilight.enable = true;
  hardware.bluetooth = {
    package = pkgs.bluez5-experimental;
    enable = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;
  services.upower.enable = true;
}
