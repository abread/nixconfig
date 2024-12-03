{
  modulesPath,
  inputs,
  profiles,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    profiles.headless
    profiles.fail2ban
    profiles.firefly
    profiles.firefly-data-importer
  ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # Networking
  networking.interfaces.ens3 = {
    ipv6 = {
      addresses = [
        {
          address = "2001:41d0:304:200::8a43";
          prefixLength = 128;
        }
      ];
      routes = [
        {
          address = "2001:41d0:304:200::1";
          prefixLength = 128;
          options.scope = "link";
        }
        {
          address = "::";
          prefixLength = 0;
          via = "2001:41d0:304:200::1";
        }
      ];
    };
  };

  users.users.root.hashedPassword = inputs.hidden.userHashedPasswords.vps.root;
}
