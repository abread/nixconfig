{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-programs-sqlite = {
      # command-not-found
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hidden.url = "git+file:///home/breda/Documents/nixconfig/hidden";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    lib = nixpkgs.lib.extend (self: super:
      import ./lib {
        inherit inputs profiles pkgs nixosConfigurations;
        lib = self;
      });

    overlays = lib.rnl.mkOverlays ./overlays;
    pkgs = lib.rnl.mkPkgs overlays;
    nixosConfigurations = lib.rnl.mkHosts ./hosts;
    profiles = lib.rnl.mkProfiles ./profiles;
  in {
    inherit nixosConfigurations overlays;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
