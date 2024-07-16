{
  lib,
  inputs,
  config,
  profiles,
  ...
}: let
  adminUserName = "admin";
  deployUserName = "deploy";
in {
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

  users.users = {
    # Configure admin user
    "${adminUserName}" = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = config.users.users.root.hashedPassword;
      openssh.authorizedKeys.keys = inputs.hidden.headlessAdminAuthorizedKeys;
    };

    # Configure deploy user
    "${deployUserName}" = {
      isNormalUser = true;
      hashedPassword = "!"; # no password login allowed
      openssh.authorizedKeys.keys = inputs.hidden.headlessDeployAuthorizedKeys;
    };
  };

  # Allow deploy user to deploy
  modules.herdnix.deploymentUser = deployUserName;

  # Ensure VPN is running and that firewall holes are pre-punched
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Ensure starship shows the hostname at all times
  programs.starship.settings.hostname.ssh_only = lib.mkIf config.programs.starship.enable false;
}
