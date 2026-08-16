{
  stdenv,
  lib,
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
    homepage = "https://github.com/quarkiverse/quarkus-systemd-notify";
    description = "Notify Linux service manager (systemd) about start-up completion and other service status changes";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.asl20;
    maintainers = with maintainers; [ rhysmdnz ];
  };
}
