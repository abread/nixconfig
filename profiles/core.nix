{
  inputs,
  pkgs,
  lib,
  config,
  profiles,
  ...
}: {
  imports = [
    profiles.shell
  ];

  nix = {
    # Improve nix store disk usage
    gc = {
      automatic = true;
      randomizedDelaySec = "30min";
      dates = "03:15";
    };

    settings = {
      # rebuild stuff as needed
      fallback = true;

      # we demand flakes
      experimental-features = ["nix-command" "flakes"];

      # accept derivations built by build hosts
      trusted-public-keys = builtins.attrValues inputs.hidden.buildHostPubkeys;

      # do not allow randos to add binaries to the store by default
      trusted-users = [];
    };
  };

  # Show diff of updates
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  };

  # Configure base network
  networking = {
    nftables.enable = lib.mkDefault true; # seems to be in use anyway
    firewall.enable = lib.mkDefault true;
    domain = lib.mkDefault "breda.pt";
  };

  # Configure NTP
  time.timeZone = lib.mkDefault "Europe/Lisbon";

  # Configure locale
  console.keyMap = lib.mkDefault "pt-latin9";
  services.xserver.xkb.layout = "pt,us";
  i18n = {
    defaultLocale = lib.mkDefault "en_US.utf8";
    extraLocaleSettings = lib.mkDefault {
      LC_ADDRESS = "pt_PT.utf8";
      LC_IDENTIFICATION = "pt_PT.utf8";
      LC_MEASUREMENT = "pt_PT.utf8";
      LC_MONETARY = "pt_PT.utf8";
      LC_NAME = "pt_PT.utf8";
      LC_NUMERIC = "pt_PT.utf8";
      LC_PAPER = "pt_PT.utf8";
      LC_TELEPHONE = "pt_PT.utf8";
      LC_TIME = "pt_PT.utf8";
    };
  };

  # Set issue message
  environment.etc."issue".text = lib.mkDefault ''
    \e[1;31m« Welcome to \n »\e[0m

    System: \e[0;37m\s \m \r \e[0m
    Users: \e[1;35m\U\e[0m

    IPv4: \e[1;34m\4\e[0m
    IPv6: \e[1;34m\6\e[0m
  '';

  # TODO: Configure email (?)
  #programs.msmtp = {
  #  enable = true;
  #  setSendmail = true;
  #  defaults = {
  #    from = "%U@%C.${config.rnl.domain}";
  #  };
  #  accounts = {
  #    "default" = {
  #      host = config.rnl.mailserver.host;
  #      port = config.rnl.mailserver.port;
  #      tls = "off";
  #      tls_starttls = "off";
  #    };
  #  };
  #};

  # have a VPN across all devices
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = "client";
  };
  networking.networkmanager.unmanaged = ["interface-name:tailscale0"];

  services.resolved = {
    enable = true;
    fallbackDns = ["2606:4700:4700::1111" "1.0.0.1" "2606:4700:4700::1001" "1.1.1.1"];
  };

  # Disable manual user management
  users.mutableUsers = lib.mkDefault false;

  system.stateVersion = "23.11"; # DO NOT CHANGE
}
