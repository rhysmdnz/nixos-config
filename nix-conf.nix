{ config, pkgs, ... }:

{
  nix = {
    gc.automatic = true;
    gc.options = "-d";
    settings.auto-optimise-store = if pkgs.stdenv.isDarwin then false else true;
    settings.trusted-users = [ "rhys" ];
    settings.substituters = [ "https://cache.memes.nz/cache" ];
    settings.trusted-public-keys = [ "cache:/89NJtgM/IWySqvXSsfNiWWOhSdXcOj6AmHZcVkwLyA=" ];
    package = pkgs.nixVersions.latest;
    generateNixPathFromInputs = true;
    linkInputs = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
