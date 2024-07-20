{
  lib,
  inputs,
  ...
}: let
  secureBootDir = "/nix/secrets/secureboot/";
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    loader = {
      grub.enable = lib.mkForce false;
      systemd-boot.enable = lib.mkForce false;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = secureBootDir;
    };
  };

  # I think lanzaboote&friends probably expected secureboot stuff to be in /etc/secureboot
  environment.etc.secureboot.source = secureBootDir;
}
