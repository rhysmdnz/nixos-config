{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    intuneNixpkgs.follows = "nixpkgs";
    pieNixpkgs.url = "github:rhysmdnz/nixpkgs/bootstrap-hacks";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    #lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.intune-patch = {
    url = https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/221628.patch;
    flake = false;
  };

  inputs.pie-patch = {
    url = https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/252310.patch;
    flake = false;
  };

 # inputs.bootstrap-patch = {
 #   url = https://github.com/rhysmdnz/nixpkgs/commit/7038fb566e63e3d0bc6d4337e773df3d5c75e96b.diff;
 #   flake = false;
 #};

  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, emacs, darwin, lanzaboote, utils, intuneNixpkgs, pieNixpkgs, intune-patch, nix-index-database, pie-patch, ... } @ inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };


      channels.intuneNixpkgs.patches = [
        intune-patch
      ];

      channels.pieNixpkgs.patches = [
        #bootstrap-patch
        #pie-patch
      ];

      sharedOverlays = [ emacs.overlay ];

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

      hosts.normandy-test = {
        channelName = "pieNixpkgs";
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
          normandy-test = self.nixosConfigurations.normandy-test.config.system.build.toplevel;
        };
      };
    };

}
