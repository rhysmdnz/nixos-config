{ stdenv
, lib
, fetchurl
, dpkg
, sdbus-cpp
}:
stdenv.mkDerivation rec {
  pname = "msalsdk-dbusclient";
  version = "1.0.1";

  src = fetchurl {
    url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/m/${pname}/${pname}_${version}_amd64.deb";
    hash = "sha512-Y5uz0+bIpw0Em2vbE8DyqahXIpfmvTguac73dDTl5AOks3/3LnSR9VticHnZKeHsWSCDvbOFZFnasUYej9nTSQ==";
  };

  nativeBuildInputs = [ dpkg ];

  buildInputs = [ stdenv.cc.cc.lib sdbus-cpp ];

  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';

  libPath = lib.makeLibraryPath buildInputs;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    install -m 755 usr/lib/libmsal_dbus_client.so $out/lib/
    patchelf --set-rpath ${libPath} $out/lib/libmsal_dbus_client.so
    runHook postInstall
  '';

  meta = with lib; {
    description = "Microsoft Authentication Library cross platform Dbus client for talking to microsoft-identity-broker";
    homepage = "https://github.com/AzureAD/microsoft-authentication-library-for-cpp";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ rhysmdnz ];
  };
}
