{ config, pkgs, ... }:

{
  nix = {
    gc.automatic = true;
    gc.options = "-d";
    settings.auto-optimise-store = true;
    settings.trusted-users = [ "rhys" ];
    settings.substituters = [ "https://nix-cache.memes.nz/nix-cache/" ];
    settings.trusted-public-keys = [ "nix-cache:JW9dxrc5qdmyDkUstVqjlVcBpunX4Jo6ueshaJIWCK4=" ];
    package = pkgs.nixUnstable;
    generateNixPathFromInputs = true;
    linkInputs = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
