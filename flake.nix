{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, emacs, darwin, lanzaboote, utils, nix-index-database, nixos-hardware, ... } @ inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      hostDefaults.modules = [
        nix-index-database.nixosModules.nix-index
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rhys = {
            imports = [ nix-doom-emacs.hmModule ./home.nix ];
          };
        }
      ];

      hosts.idenna = {
        system = "aarch64-darwin";
        output = "darwinConfigurations";
        builder = darwin.lib.darwinSystem;

        modules = [
          ./idenna.nix
          home-manager.darwinModules.home-manager
        ];
      };

      hosts.normandy = {
        modules = [
          ./nixos.nix
          ./normandy.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
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
        ];
      };

      herculesCI.onPush.default = {
        outputs = { ... }: {
          elbrus = self.nixosConfigurations.elbrus.config.system.build.toplevel;
          normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
        };
      };
    };

}
