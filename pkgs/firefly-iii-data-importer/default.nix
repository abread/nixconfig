{
  lib,
  fetchzip,
  stdenv,
  makeWrapper,
  php83,
  ...
}: let
  version = "1.5.5";
  php = php83;
in
  stdenv.mkDerivation {
    pname = "firefly-iii-data-importer";
    inherit version;

    src = fetchzip {
      url = "https://github.com/firefly-iii/data-importer/releases/download/v${version}/DataImporter-v${version}.zip";
      hash = "sha256-4M5yC3+gitE8Pc5G8CVn3OUSIDj/NpaW22H/v7qkgFs=";
      stripRoot = false;
    };

    patches = [
      ./firefly-storage-path.patch
    ];

    nativeBuildInputs = [makeWrapper php];

    installPhase = ''
      mkdir -p "$out"
      cp -r * "$out"/
      cp -r .* "$out"/

      wrapProgram "$out/artisan" --set PATH ${lib.makeBinPath [php]}
    '';
  }
