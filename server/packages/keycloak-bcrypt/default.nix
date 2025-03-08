{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "keycloak-bcrypt";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/leroyguillaume/keycloak-bcrypt/releases/download/${version}/keycloak-bcrypt-${version}.jar";
    sha256 = "sha256-iqIHDEoPX42rNirxMUUf/57lzOPL3q1McoQ9tO9vKq8=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    install "$src" "$out"
  '';

  meta = with lib; {
    homepage = "https://github.com/leroyguillaume/keycloak-bcrypt";
    description = "Add BCrypt password provider in Keycloak";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.apsl20;
    maintainers = with maintainers; [ rhysmdnz ];
  };
}
