{
  config,
  inputs,
  lib,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    enable = true;
    serverTokens = false;

    # Enable recommended settings
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    # recommendedZstdSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    sslDhparam = config.security.dhparams.params.nginx.path;
  };

  security.dhparams = {
    enable = true;
    params.nginx = { };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    reloadServices = [ "nginx" ];
    email = inputs.hidden.robotsEmail "acme-${config.networking.hostname}";
    dnsProvider = "ovh";
    environmentFile = "/var/acme_env"; # TODO: better/safer way to store this?

    group = config.services.nginx.group;
  };

  # Always use Nginx
  services.httpd.enable = lib.mkForce false;

  # Override the user and group to match the Nginx ones
  # Since some services uses the httpd user and group
  services.httpd = {
    user = lib.mkForce config.services.nginx.user;
    group = lib.mkForce config.services.nginx.group;
  };
}
