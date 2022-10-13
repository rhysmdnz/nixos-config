{
  inputs = {
    nixpkgsTweaks.url = "github:rhysmdnz/nixpkgs/bootspec-rfc";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
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

  outputs = { self, nixpkgs, nixpkgsTweaks, flake-compat-ci, home-manager, nix-doom-emacs, emacs, bootspec-secureboot, darwin, ... }:

    let
      patchedNixpkgs = nixpkgsTweaks.legacyPackages.x86_64-linux.applyPatches {
        name = "patched-nixpkgs-source";
        src = nixpkgsTweaks.outPath;
        patches = [
          (nixpkgsTweaks.legacyPackages.x86_64-linux.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/189676.patch";
            sha256 = "sha256-hZfvNG1nH+M3ysOs2prIRE5nqodZsDZV5+RsipKpI18=";
          })
        ];
      };
      coolNixosSystem = import "${patchedNixpkgs}/nixos/lib/eval-config.nix";
    in
    {
      nixosConfigurations.normandy = coolNixosSystem {
        system = "x86_64-linux";
        modules = [
          bootspec-secureboot.nixosModules.bootspec-secureboot
          { nixpkgs.overlays = [ emacs.overlay ]; }
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

      #nixosConfigurations.normandyTest = nixpkgsHardened.lib.nixosSystem {
      #  system = "x86_64-linux";
      #  modules = [
      #    { nixpkgs.overlays = [ emacs.overlay ]; }
      #    ./normandy.nix
      #    home-manager.nixosModules.home-manager
      #    {
      #      home-manager.useGlobalPkgs = true;
      #      home-manager.useUserPackages = true;
      #      home-manager.users.rhys = {
      #        imports = [ nix-doom-emacs.hmModule ./home.nix ];
      #      };
      #    }
      #  ];
      #};

      nixosConfigurations.elbrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ emacs.overlay ]; }
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
      ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
        flake = self;
        systems = [ "x86_64-linux" ];
      };
    };
}
