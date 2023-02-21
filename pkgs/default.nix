{ pkgs ? import <nixpkgs> { } }: {
  microsoft-identity-broker = pkgs.callPackage ./microsoft-identity-broker { };
  intune-portal = pkgs.callPackage ./intune-portal { };
  msalsdk-dbusclient = pkgs.callPackage ./msalsdk-dbusclient { };
  jnr-posix = pkgs.callPackage ./jnr-posix { };
}
