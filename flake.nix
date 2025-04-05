{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgsServer.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      lanzaboote,
      utils,
      nix-index-database,
      nixos-hardware,
      ...
    }@inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig = {
        allowUnfree = true;
      };

      # channels.nixpkgsServer.patches = [ ./server/njs-zlib.patch ];

      hostDefaults.modules = [

      ];

      hosts.idenna = {
        system = "aarch64-darwin";
        output = "darwinConfigurations";
        builder = darwin.lib.darwinSystem;

        modules = [
          ./idenna.nix
          home-manager.darwinModules.home-manager
          nix-index-database.darwinModules.nix-index
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [
                inputs.nix-doom-emacs-unstraightened.hmModule
                ./home.nix
              ];
            };
          }
        ];
      };

      hosts.normandy = {
        modules = [
          ./nixos.nix
          ./normandy.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.nix-index
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [
                inputs.nix-doom-emacs-unstraightened.hmModule
                ./home.nix
              ];
            };
          }
        ];
      };

      hosts.elbrus = {
        modules = [
          ./nixos.nix
          ./elbrus.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-nvidia-disable
          nix-index-database.nixosModules.nix-index
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [
                inputs.nix-doom-emacs-unstraightened.hmModule
                ./home.nix
              ];
            };
          }
        ];
      };

      hosts.memesnz1 = {
        channelName = "nixpkgsServer";
        modules = [
          ./nix-conf.nix
          ./server/configuration.nix
          nix-index-database.nixosModules.nix-index
        ];
      };
    };

}
