{
  lib,
  withSystem,
  inputs,
  ...
} @ args: let
  inherit (lib.rnl) rakeLeaves;

  /*
  *
  Synopsis: mkProfiles profilesDir

  Generate profiles from the Nix expressions found in the specified directory.

  Inputs:
  - profilesDir: The path to the directory containing Nix expressions.

  Output Format:
  An attribute set representing profiles.
  The function uses the `rakeLeaves` function to recursively collect Nix files
  and directories within the `profilesDir` directory.
  The result is an attribute set mapping Nix files and directories
  to their corresponding keys.

  *
  */

  mkProfiles = profilesDir: rakeLeaves profilesDir;

  /*
  *
  Synopsis: mkHost hostname  { system, hostPath, extraModules ? [] }

  Generate a NixOS system configuration for the specified hostname.

  Inputs:
  - hostname: The hostname for the target NixOS system.
  - system: The target system platform (e.g., "x86_64-linux").
  - hostPath: The path to the directory containing host-specific Nix configurations.
  - extraModules: An optional list of additional NixOS modules to include in the configuration.

  Output Format:
  A NixOS system configuration representing the specified hostname. The function generates a NixOS system configuration using the provided parameters and additional modules. It inherits attributes from `pkgs`, `lib`, `profiles`, `inputs`, and other custom modules.

  *
  */

  mkHost = hostname: {
    system,
    hostPath,
    profiles,
    extraModules ? [],
    ...
  }:
    withSystem system ({pkgs, ...}:
      lib.nixosSystem {
        inherit system pkgs lib;
        specialArgs = {inherit profiles inputs;};
        modules =
          (lib.collect builtins.isPath (lib.rnl.rakeLeaves ../modules))
          ++ [
            {networking.hostName = hostname;}
            hostPath
          ]
          ++ extraModules;
      });

  /*
  *
  Synopsis: mkHosts hostsDir

  Generate a set of NixOS system configurations for the hosts defined in the specified directory.

  Inputs:
  - hostsDir: The path to the directory containing host-specific configurations.

  Output Format:
  An attribute set representing NixOS system configurations for the hosts
  found in the `hostsDir`. The function scans the `hostsDir` directory
  for host-specific Nix configurations and generates a set of NixOS
  system configurations for each host. The resulting attribute set maps
  hostnames to their corresponding NixOS system configurations.
  *
  */
  mkHosts = hostsDir: extraCfg:
    lib.listToAttrs (lib.lists.flatten (lib.mapAttrsToList (name: type: let
        # Get hostname from host path
        hostPath = hostsDir + "/${name}";
        configPath = hostPath + "/configuration.nix";
        hostname = lib.removeSuffix ".nix" (builtins.baseNameOf hostPath);

        # Merge default configuration with host configuration (if it exists)
        cfg =
          {
            inherit hostPath inputs;
            system = "x86_64-linux"; # default, may be overridden by hostCfg
            aliases = null;
          }
          // extraCfg
          // hostCfg;

        hostCfg =
          lib.optionalAttrs
          (type == "directory" && builtins.pathExists configPath)
          (import configPath args);

        # Remove aliases from host configuration
        # and merge aliases with hosts
        aliases' =
          if (cfg.aliases != null)
          then cfg.aliases
          else {${hostname} = {extraModules = [];};};
        cfg' = lib.filterAttrs (name: _: name != "aliases") cfg;
        aliases = lib.mapAttrs (_: value: (value // cfg')) aliases';
      in
        lib.mapAttrsToList (hostname: alias: {
          name = hostname;
          value = mkHost hostname alias;
        })
        aliases)
      # Ignore hosts starting with an underscore
      (lib.filterAttrs (path: _: !(lib.hasPrefix "_" path)) (builtins.readDir hostsDir))));
in {
  inherit mkProfiles mkHosts;
}
