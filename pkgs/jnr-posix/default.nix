{ stdenv
, lib
, fetchFromGitHub
, dpkg
, openjdk11
, makeWrapper
, maven
, which
}:
let
  pname = "jnr-posix";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "jnr";
    repo = "jnr-posix";
    rev = "jnr-posix-${version}";
    hash = "sha512-oNNjTydn697Hn8MgGsZsbVbJoetc8lBM80WFh4b7KtJg5B6OZuSsqASyQHB5HLNkCGu9aHw8ViB8aon2HCQBEQ==";
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;

    nativeBuildInputs = [ openjdk11 maven ];

    buildPhase = ''
      ls -la
      mvn package -Dmaven.test.skip=true -Dmaven.repo.local=$out/.m2 -Dmaven.wagon.rto=5000
    '';

    # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
    installPhase = ''
      find $out/.m2 -type f -regex '.+\(\.lastUpdated\|resolver-status\.properties\|_remote\.repositories\)' -delete
      find $out/.m2 -type f -iname '*.pom' -exec sed -i -e 's/\r\+$//' {} \;
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-ZMEDl/ZJolWgB7XipqCvjA9Ubig845FT6PUzmy2Q6q8=";

    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  inherit version pname src;

  nativeBuildInputs = [ openjdk11 maven which ];

  patchPhase = ''
    sed -i "s/\/usr\/bin\/id/$(which id | sed 's#/#\\/#g')/g" src/main/java/jnr/posix/JavaPOSIX.java
  '';

  buildPhase = ''
    mvn package --offline -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D target/${pname}-${version}.jar $out/share/java/${pname}-${version}.jar
  '';

  meta = with lib; {
    description = "jnr-posix is a lightweight cross-platform POSIX emulation layer for Java, written in Java and is part of the JNR project";
    homepage = "https://github.com/jnr/jnr-posix";
    license = with licenses; [ epl20 gpl2Only lgpl21Only ];
    maintainers = with lib.maintainers; [ rhysmdnz ];
  };
}
