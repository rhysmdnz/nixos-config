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
    lanzaboote.url = "github:nix-community/lanzaboote/v0.2.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  inputs.intune-patch = {
    url = https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/221628.patch;
    flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, emacs, darwin, lanzaboote, utils, intuneNixpkgs, intune-patch, ... } @ inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels.intuneNixpkgs.patches = [
        intune-patch
      ];

      sharedOverlays = [ emacs.overlay ];

      hostDefaults.modules = [
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
        channelName = "intuneNixpkgs";
        modules = [
          ./nixos.nix
          ./elbrus.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
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
