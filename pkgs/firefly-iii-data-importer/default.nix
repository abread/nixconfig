{
  lib,
  fetchzip,
  stdenv,
  makeWrapper,
  php83,
  ...
}: let
  version = "1.5.4";
  php = php83;
in
  stdenv.mkDerivation {
    pname = "firefly-iii-data-importer";
    inherit version;

    src = fetchzip {
      url = "https://github.com/firefly-iii/data-importer/releases/download/v${version}/DataImporter-v${version}.zip";
      hash = "sha256-+c5BLaca1PVILUERb8OALX3nRQ27+i6k2gpZ6axpFIM=";
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
