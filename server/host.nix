{ flake, ... }:

{
  imports = [
    ../nix-conf.nix
    ./configuration.nix
    flake.inputs.nix-index-database.nixosModules.nix-index
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "memesnz1";

  nixpkgs.config.permittedInsecurePackages = [ "minio-2025-10-15T17-29-55Z" ];
}
