{
  lib,
  inputs,
  config,
  profiles,
  ...
}: {
  imports = [
    profiles.core
  ];

  # Enable regular SSH (because I don't trust tailscale to always work)
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      # UseDNS = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
  };

  users = {
    # Configure deploy user
    users.admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = config.users.users.root.hashedPassword;
      openssh.authorizedKeys.keys = inputs.hidden.headlessAuthorizedKeys;
    };
  };

  # Allow deploy user to deploy
  modules.simple-deployer.deploymentUser = deployUserName;

  # Ensure VPN is running and that firewall holes are pre-punched
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Ensure starship shows the hostname at all times
  programs.starship.settings.hostname.ssh_only = lib.mkIf config.programs.starship.enable false;
}
