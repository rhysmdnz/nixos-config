{ config, pkgs, ... }:

{
  nix = {
    autoOptimiseStore = true;
    binaryCaches = [ "https://nix-cache.memes.nz/nix-cache/" ];
    binaryCachePublicKeys = [ "nix-cache:JW9dxrc5qdmyDkUstVqjlVcBpunX4Jo6ueshaJIWCK4=" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
