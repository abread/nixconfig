{
  lib,
  config,
  ...
}: {
  networking.useDHCP = false;
  networking.networkmanager = {
    enable = true;
    #unmanaged = ["type:wireguard"];
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
    #wifi.backend = "iwd"; # painful meme. seemed unstable and forced me to re-add all networks
    dns = "systemd-resolved";
  };

  networking.wgrnl = lib.mkIf (config.networking.wgrnl.id != null) {
    enable = true;
    ownPrivateKeyFile = "/nix/secrets/wgrnl-privkey";
  };
}
