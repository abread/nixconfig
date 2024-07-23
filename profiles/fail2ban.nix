{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config) services;
in {
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      # VPN IPs
      "100.0.0.0/8"
    ];

    maxretry = 3;

    # Make sure bantime is >=15m for all jails (default is 10m).
    # Abuseipdb only allows reporting the same IP once every 15m.
    bantime = "1h";
    bantime-increment = {
      enable = true;
      rndtime = "30m";
      maxtime = "168h"; # Do not ban for more than 1 week
    };

    # use nftables, yes, but drop traffic, not reject it
    banaction = "nftables[type=multiport,blocktype=drop]";
    banaction-allports = "nftables[type=allports,blocktype=drop]";

    #extraPackages = [pkgs.system-sendmail];
    # TODO: Configure abuseipdb action
    # TODO: Configure email action

    jails = {
      # postfix
      postfix = mkIf services.postfix.enable ''
        enabled = true
        filter = postfix
      '';
      # courier

      # nginx-botsearch
      nginx-botsearch = mkIf services.nginx.enable ''
        enabled = true
        filter = nginx-botsearch
      '';

      # php-url-fopen
      php-url-fopen = mkIf services.nginx.enable ''
        enabled = true
        filter = php-url-fopen
        maxretry = 1
      '';

      # sshd jail built-in
    };
  };
}
