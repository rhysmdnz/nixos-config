{ flake, pkgs, ... }:

let
  src = flake.inputs.grimmory-src;
in
{
  imports = [ "${src}/nixos/modules/services/web-apps/grimmory.nix" ];

  services.grimmory = {
    enable = true;
    package = pkgs.callPackage "${src}/pkgs/by-name/gr/grimmory/package.nix" { };
    host = "0.0.0.0";
    port = 7070;
    booksDir = "/mnt/s/books";
    database = {
      name = "booklore";
      user = "booklore";
      passwordFile = "/var/lib/grimmory-secrets/db-password";
    };
  };
}
