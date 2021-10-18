{ config, pkgs, ... }:

{
  nix = {
    autoOptimiseStore = true;
    binaryCaches = [ "s3://nix-cache?region=us-east-1&endpoint=nix-cache.memes.nz" ];
    binaryCachePublicKeys = [ "nix-cache:JW9dxrc5qdmyDkUstVqjlVcBpunX4Jo6ueshaJIWCK4=" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
