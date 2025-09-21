{ config, pkgs, ... }:

{
  nix = {
    gc.automatic = true;
    gc.options = "-d";
    settings.auto-optimise-store = if pkgs.stdenv.isDarwin then false else true;
    settings.trusted-users = [ "rhys" ];
    settings.substituters = [
      "https://cache.memes.nz/cache"
      "https://nix-community.cachix.org"
    ];
    settings.trusted-public-keys = [
      "cache:/89NJtgM/IWySqvXSsfNiWWOhSdXcOj6AmHZcVkwLyA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    package = pkgs.nixVersions.latest;
    generateNixPathFromInputs = true;
    linkInputs = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
