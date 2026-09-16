{ flake, ... }:

{
  imports = [
    ../nix-conf.nix
    ./configuration.nix
    flake.inputs.nix-index-database.nixosModules.nix-index
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "memesnz1";
}
