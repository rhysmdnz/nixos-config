{ config, pkgs, ... }:

{
  nix = {
    gc.automatic = true;
    gc.options = "-d";
    settings.auto-optimise-store = if pkgs.stdenv.isDarwin then false else true;
    settings.trusted-users = [ "rhys" ];
    settings.substituters = [ "https://nix-cache.memes.nz/nix-cache/" "https://cache.memes.nz/cache" ];
    settings.trusted-public-keys = [ "nix-cache:JW9dxrc5qdmyDkUstVqjlVcBpunX4Jo6ueshaJIWCK4=" "cache:/89NJtgM/IWySqvXSsfNiWWOhSdXcOj6AmHZcVkwLyA=" ];
    package = pkgs.nixUnstable;
    generateNixPathFromInputs = true;
    linkInputs = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
