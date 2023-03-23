{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    intuneNixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay/c16be6de78ea878aedd0292aa5d4a1ee0a5da501";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  inputs.bootspec-secureboot = {
    url = "github:DeterminateSystems/bootspec-secureboot/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.intune-patch = {
    url = https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/221628.patch;
    flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, emacs, bootspec-secureboot, darwin, lanzaboote, utils, intuneNixpkgs, intune-patch, ... } @ inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channels.intuneNixpkgs.patches = [
        intune-patch
      ];

      hosts.idenna = {
        system = "aarch64-darwin";
        output = "darwinConfigurations";
        builder = darwin.lib.darwinSystem;

        modules = [
          ./idenna.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.rhys = {
              imports = [ nix-doom-emacs.hmModule ./home.nix ];
            };
          }
        ];
      };

      hosts.normandy = {
        modules = [
          bootspec-secureboot.nixosModules.bootspec-secureboot
          { nixpkgs.overlays = [ emacs.overlay ]; }
          ./nixos.nix
          ./normandy.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [ nix-doom-emacs.hmModule ./home.nix ];
            };
          }
        ];
      };

      hosts.elbrus = {
        channelName = "intuneNixpkgs";
        modules = [
          { nixpkgs.overlays = [ emacs.overlay ]; }
          ./nixos.nix
          ./elbrus.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [ nix-doom-emacs.hmModule ./home.nix ];
            };
          }
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
