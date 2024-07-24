{
  inputs,
  profiles,
  ...
}: {
  imports = [
    profiles.pc
    profiles.secureboot
  ];

  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.kernelParams = [
    "acpi_backlight=native"
    "tsc=unstable" # TSC clock is unstable, disabling, yada yada yada
    "tpm_tis.interrupts=0" # [Firmware Bug]: TPM interrupt not working, polling instead
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d195ff4a-4782-4ae9-9526-7e282082071f";
    fsType = "ext4";
    options = ["defaults" "discard" "relatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B47E-8239";
    fsType = "vfat";
    options = ["defaults" "relatime"];
  };

  fileSystems."/home" = {
    mountPoint = "/home";
    device = "/dev/disk/by-uuid/a0d0fdf0-6918-4af7-b95b-9272e89da6c9";
    fsType = "btrfs";
    options = ["defaults" "discard" "relatime"];
  };

  fileSystems."/home/breda/ram" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["rw" "nosuid" "nodev" "noexec" "relatime" "size=10G" "uid=1001" "gid=1001" "inode64"];
    depends = ["/home"];
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/8200fbf7-762e-4275-b91f-9b0397f33e5c";
      priority = 1;
    }
  ];

  zramSwap = {
    enable = true;
    priority = 10;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  users.users.root.hashedPassword = inputs.hidden.userHashedPasswords.tightpants.root;

  # we have a smartcard reader!
  services.pcscd.enable = true;

  # we have an SSD
  services.fstrim.enable = true;

  # we have a key for wireguard!
  networking.wgrnl.id = 12;

  # these USBs cannot have powersave on
  powerManagement.powerUpCommands = ''
    echo on > /sys/bus/usb/devices/usb3/power/control
    echo on > /sys/bus/usb/devices/usb1/power/control
  '';

  services.restic.backups.tightpants = {
    repository = "rclone:b2-backups-tightpants:backups-tightpants/";
    rcloneConfigFile = "/home/breda/.config/rclone/rclone.conf";
    passwordFile = "/nix/persist/restic-password";
    paths = ["/home/breda" "/etc/nixos" "/etc/NetworkManager/system-connections"];
    pruneOpts = ["--dry-run"];
    extraBackupArgs = ["--compression" "max" "--pack-size" "128" "--one-file-system" "--exclude-caches" "--exclude-file /home/breda/.config/restic/excludes.txt"];
    timerConfig = {
      OnCalendar = "Mon,Wed,Fri,Sun *-*-* 00:00:00";
      Persistent = true;
      WakeSystem = false;
      RandomizedDelaySec = 86400;
      AccuracySec = 3600;
    };
  };
}
