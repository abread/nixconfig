{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  dpkg,
  jre,
  pcsclite,
  ...
}:
stdenv.mkDerivation rec {
  pname = "plugin-autenticacao-gov";
  version = "20240808"; # no real versioning scheme

  src = fetchurl {
    url = "https://aplicacoes.autenticacao.gov.pt/plugin/plugin-autenticacao-gov.deb";
    hash = "sha256-DGQka4HkyeOLI61Thzndc4IE3TsqzgqtLBVUnK+pIx4=";
  };

  nativeBuildInputs = [
    makeWrapper
    dpkg
  ];
  buildInputs = [ pcsclite ];

  unpackPhase = ''
    mkdir deb
    dpkg-deb -R $src deb
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv deb/usr/share $out/

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pcsclite ]} \
      --add-flags "-Dsun.java2d.xrender=false" \
      --add-flags "-jar $out/share/${pname}/${pname}.jar" \
      --add-flags "sj"
    sed -E "s|^Exec=.*|Exec=$out/bin/${pname}|" $out/share/applications/plugin-autenticacao-gov.desktop
  '';

  meta = {
    description = "O plugin Autenticação.Gov é o mecanismo que permite utilizar o Cartão de Cidadão eficientemente e em segurança nos navegadores";
    homepage = "https://autenticacao.gov.pt/fa/ajuda/autenticacaogovpt.aspx";
    license = lib.licenses.eupl11;
  };
}
