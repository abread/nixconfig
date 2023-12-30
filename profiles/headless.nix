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

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
