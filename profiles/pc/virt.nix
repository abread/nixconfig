{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.virt-manager
    pkgs.docker-compose
    pkgs.podman-compose
  ];

  virtualisation = {
    podman = {
      enable = true;
    };
    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
    };
    docker = {
      enable = true;
      enableOnBoot = false;
      autoPrune.enable = true;
      liveRestore = false; # for docker swarm compat
    };
  };
}
