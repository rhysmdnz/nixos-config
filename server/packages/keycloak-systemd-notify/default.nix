{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "keycloak-systemd-notify";
  version = "1.5.1";

  src = ./quarkus-systemd-notify-1.0.2.jar;
  src2 = ./quarkus-systemd-notify-deployment-1.0.2.jar;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    install "$src" "$out"
    install "$src2" "$out"
  '';

  meta = with lib; {
    homepage = "https://github.com/leroyguillaume/keycloak-bcrypt";
    description = "Add BCrypt password provider in Keycloak";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.apsl20;
    maintainers = with maintainers; [ rhysmdnz ];
  };
}
