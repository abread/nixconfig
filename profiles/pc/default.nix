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

    ./flatpak.nix
    ./devtools.nix
    ./network.nix
    ./virt.nix
    ./user-breda
  ];

  # for now PCs can be build hosts
  nix.extraOptions = ''
    secret-key-files = /nix/secrets/nix-build-priv-key
  '';
  modules.herdnix.deploymentUser = "breda";

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
}
