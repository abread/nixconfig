{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      inputs.pre-commit-hooks.follows = "";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # We only have these inputs to pass to other dependencies and
    # avoid having multiple versions in our flake.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib.extend (final: _prev:
      import ./lib {
        inherit inputs profiles multiPkgs nixosConfigurations;
        lib = final;
      });
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    ownPkgBuilder = pkgs: (lib.mapAttrsRecursive
      (_: path: (pkgs.callPackage path {inherit inputs;}))
      (lib.rnl.rakeLeaves ./pkgs));
    ownPkgsOverlay = _final: prev: ownPkgBuilder prev;
    multiPkgs = forAllSystems (system: lib.rnl.mkPkgs system [ownPkgsOverlay]);
    profiles = lib.rnl.mkProfiles ./profiles;
    nixosConfigurations = lib.rnl.mkHosts ./hosts;
  in {
    inherit nixosConfigurations;

    overlays.default = ownPkgsOverlay;

    packages =
      lib.recursiveUpdate
      (forAllSystems (system: ownPkgBuilder inputs.nixpkgs.legacyPackages.${system}))
      (inputs.herdnix.genHerdnixHostsPackages nixosConfigurations);

    apps = forAllSystems (system: {
      herdnix = {
        type = "app";
        program = "${inputs.herdnix.packages.${system}.herdnix}/bin/herdnix";
      };
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
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
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        packages = [inputs.herdnix.packages.${system}.herdnix];
      };
    });
  };
}
