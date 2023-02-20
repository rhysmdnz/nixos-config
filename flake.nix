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
  };

  inputs.bootspec-secureboot = {
    url = "github:DeterminateSystems/bootspec-secureboot/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, emacs, bootspec-secureboot, darwin, ... }:
let
       patchedNixpkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
         name = "patched-nixpkgs-source";
         src = nixpkgs.outPath;
         patches = [
           ./llvm.patch
         ];
       };
       coolNixosSystem = import "${patchedNixpkgs}/nixos/lib/eval-config.nix";
     in
    {
      nixosConfigurations.normandy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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

#      nixosConfigurations.normandyTest = coolNixosSystem {
#        system = "x86_64-linux";
#        modules = [
#        bootspec-secureboot.nixosModules.bootspec-secureboot
#          { nixpkgs.overlays = [ emacs.overlay ]; }
#         ./nixos.nix
#         ./normandy.nix
#          ./llvm-all.nix
#            home-manager.nixosModules.home-manager
#          {
#            home-manager.useGlobalPkgs = true;
#            home-manager.useUserPackages = true;
#            home-manager.users.rhys = {
#             imports = [ nix-doom-emacs.hmModule ./home.nix ];
#            };
#          }
#        ];
#      };

      nixosConfigurations.elbrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ emacs.overlay ]; }
          ./nixos.nix
          ./elbrus.nix
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


      darwinConfigurations.idenna = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./idenna.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = {
              imports = [ nix-doom-emacs.hmModule ./home.nix ];
            };
          }
        ];
      };

      hydraJobs.build.normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
      hydraJobs.build.normandyTest = self.nixosConfigurations.normandyTest.config.system.build.toplevel;
      herculesCI.onPush.default = {
        outputs = { ... }: {
          elbrus = self.nixosConfigurations.elbrus.config.system.build.toplevel;
          normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
          normandyTest = self.nixosConfigurations.normandyTest.config.system.build.toplevel;
        };
      };
    };
}
