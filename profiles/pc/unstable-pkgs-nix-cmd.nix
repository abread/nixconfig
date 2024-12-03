{ inputs, ... }:
{
  nix = {
    registry.unstable.flake = inputs.nixpkgs-unstable;
    nixPath = [ "unstable=${inputs.nixpkgs-unstable.outPath}" ];
  };
}
