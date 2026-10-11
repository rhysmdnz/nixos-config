{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keycloak-bcrypt";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/leroyguillaume/keycloak-bcrypt/releases/download/${finalAttrs.version}/keycloak-bcrypt-${finalAttrs.version}.jar";
    hash = "sha256-iqIHDEoPX42rNirxMUUf/57lzOPL3q1McoQ9tO9vKq8=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    install "$src" "$out"
  '';

  meta = {
    homepage = "https://github.com/leroyguillaume/keycloak-bcrypt";
    description = "Add BCrypt password provider in Keycloak";
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    license = lib.licenses.apsl20;
    maintainers = [ lib.maintainers.rhysmdnz ];
  };
})
