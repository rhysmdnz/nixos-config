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

  nix = {
    gc = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
      automatic = true;
      options = "-d";
    };
    settings.auto-optimise-store = if pkgs.stdenv.hostPlatform.isDarwin then false else true;
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
    nixPath = [ "/etc/nix/inputs" ];
    registry = lib.mapAttrs (_name: input: { flake = input; }) flake.inputs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
