{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  environment.etc = lib.mapAttrs' (name: input: {
    name = "nix/inputs/${name}";
    value.source = input.outPath;
  }) flake.inputs;

  nix = lib.mkIf config.nix.enable {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "rhys" ];
      substituters = [
        "https://cache.memes.nz/cache"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache:/89NJtgM/IWySqvXSsfNiWWOhSdXcOj6AmHZcVkwLyA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    package = pkgs.nixVersions.latest;
    nixPath = [ "/etc/nix/inputs" ];
    registry = lib.mapAttrs (_name: input: { flake = input; }) flake.inputs;
  };
}
