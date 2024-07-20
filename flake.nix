{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-programs-sqlite = {
      # command-not-found
      url = "github:wamserma/flake-programs-sqlite";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    herdnix = {
      url = "github:abread/herdnix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
    };
    hidden.url = "git+file:///home/breda/Documents/nixconfig/hidden";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # We only have this input to pass it to other dependencies and
    # avoid having multiple versions in our dependencies.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      self,
      withSystem,
      ...
    }: let
      lib = inputs.nixpkgs.lib.extend (self: _super:
        import ./lib {
          inherit inputs withSystem;
          lib = self;
        });
    in {
      imports = [
        # TODO: see if this works well
        # Derive the output overlay automatically from all packages that we define(?)
        # inputs.flake-parts.flakeModules.easyOverlay

        inputs.pre-commit-hooks.flakeModule
      ];
      flake = {
        nixosConfigurations = lib.rnl.mkHosts ./hosts {
          profiles = lib.rnl.mkProfiles ./profiles;
        };
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem = {
        config,
        system,
        inputs',
        pkgs,
        ...
      }: let
        packages =
          (
            lib.mapAttrsRecursive
            (_: path: (pkgs.callPackage path {inherit inputs';}))
            (lib.rnl.rakeLeaves ./pkgs)
          )
          // {
            # TODO: move to flake module within herdnix
            # we build it as a package to ensure nixpkgs's trivial builders work well on all platforms
            herdnix-hosts = inputs'.herdnix.packages.herdnix-hosts.override {inherit (self) nixosConfigurations;};
          };
      in {
        #warnings = let
        #  pkgConflicts = builtins.filter (pkgName: builtins.hasAttr pkgName inputs'.nixpkgs.legacyPackages) (builtins.attrNames self'.packages);
        #in builtins.map (pkgName: ''${pkgName} exists in both this flake and nixpkgs. Using the version from this flake.'') pkgConflicts;

        inherit packages;

        # Use nixpkgs with our overlays
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (import ./patches)
            (_final: _prev: packages)
          ];
        };

        apps.herdnix.program = "${inputs'.herdnix.packages.herdnix}/bin/herdnix";

        formatter = pkgs.alejandra;
        pre-commit.settings.hooks = {
          # Nix
          alejandra.enable = true;
          deadnix.enable = true;

          # Shell
          shellcheck.enable = true;
          shfmt.enable = true;

          # Git
          check-merge-conflicts.enable = true;
          forbid-new-submodules.enable = true;

          typos = {
            enable = true;
            settings.configPath = "./typos.toml";
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (config.pre-commit.devShell) shellHook buildInputs;

          packages = [
            inputs'.herdnix.packages.herdnix
          ];
        };
      };
    });
}
