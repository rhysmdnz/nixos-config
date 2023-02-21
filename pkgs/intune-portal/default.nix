{ stdenv
, lib
, fetchurl
, dpkg
, openjdk11
, jnr-posix
, makeWrapper
, libuuid
, xorg
, curlMinimal
, openssl
, libsecret
, webkitgtk
, libsoup
, gtk3
, atk
, pango
, glib
, sqlite
, zlib
, systemd
, msalsdk-dbusclient
, pam
}:
stdenv.mkDerivation rec {
  pname = "intune-portal";
  version = "1.2302.11";

  src = fetchurl {
    url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/i/${pname}/${pname}_${version}_amd64.deb";
    hash = "sha512-K/6ia1ZwBfAa5bJgp4HZnERRefz1VmNbPpAJVVfl4FA9qS5z27mUFtKX18ssmIcxjG4DN22ugR5J6zDd2E99pw==";
  };

  nativeBuildInputs = [ dpkg ];

  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';


  buildPhase =
    let
      libPath = {
        intune = lib.makeLibraryPath [ stdenv.cc.cc.lib libuuid xorg.libX11 curlMinimal openssl libsecret webkitgtk libsoup gtk3 atk glib pango sqlite zlib systemd msalsdk-dbusclient ];
        pam = lib.makeLibraryPath [ pam ];
      };
    in
    ''
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath ${libPath.intune} opt/microsoft/intune/bin/intune-portal
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath ${libPath.intune} opt/microsoft/intune/bin/intune-agent
      patchelf --set-rpath ${libPath.pam} ./usr/lib/x86_64-linux-gnu/security/pam_intune.so
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -a opt/microsoft/intune/bin/* $out/bin/
    cp -R usr/share $out
    cp -R lib $out
    cp -R ./usr/lib/x86_64-linux-gnu/security/pam_intune.so lib/

    substituteInPlace $out/share/applications/intune-portal.desktop \
      --replace /opt/microsoft/intune/bin/intune-portal $out/bin/intune-portal

    substituteInPlace $out/lib/systemd/user/intune-agent.service \
      --replace \
        ExecStart=/opt/microsoft/intune/bin/intune-agent\
        ExecStart=$out/bin/intune-agent

    runHook postInstall
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "Microsoft Authentication Library cross platform Dbus client for talking to microsoft-identity-broker";
    homepage = "https://www.microsoft.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ rhysmdnz ];
  };
}
