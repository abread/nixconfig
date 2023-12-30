{
  lib,
  config,
  ...
}: {
  imports = [];

  options.modules.simple-deployer = {
    enable = lib.mkOption {
      # we use mkOption instead of mkEnableOption to use true as the default
      type = lib.types.bool;
      description = "Whether to enable deploys to this host";
      default = true;
      example = false;
    };

    useRemoteSudo = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to use sudo to deploy this host";
      # enable when root does not have a configured SSH key
      default = config.users.users.root.openssh.authorizedKeys.keys == [];
      example = true;
    };

    targetHost = lib.mkOption {
      type = lib.types.str;
      description = "What to pass as --target-host to nixos-rebuild";
      default = config.networking.fqdnOrHostName;
      example = "user@machine.com";
    };

    defaultSelect = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to select this host for deployment by default";
      default = true;
      example = false;
    };
  };

  config = {};
}
