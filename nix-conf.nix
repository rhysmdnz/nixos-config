{ config, pkgs, ... }:

{
  nix = {
    settings.auto-optimise-store = true;
    settings.substituters = [ "https://nix-cache.memes.nz/nix-cache/" ];
    settings.trusted-public-keys = [ "nix-cache:JW9dxrc5qdmyDkUstVqjlVcBpunX4Jo6ueshaJIWCK4=" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
