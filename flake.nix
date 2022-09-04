{
  inputs = {
    nixpkgsTweaks.url = "github:rhysmdnz/nixpkgs/update-edk2";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
    home-manager.url = "github:nix-community/home-manager";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, nixpkgsTweaks, flake-compat-ci, home-manager, nix-doom-emacs, emacs, ... }:

    let
      patchedNixpkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "patched-nixpkgs-source";
        src = nixpkgs.outPath;
        patches = [
          (nixpkgs.legacyPackages.x86_64-linux.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/189676.patch";
            sha256 = "sha256-wOw+Lie8x8/rtXvxAsNoCWZrRB6PndHBCXO/ZYDbYgQ=";
          })
        ];
      };
      coolNixosSystem = import "${patchedNixpkgs}/nixos/lib/eval-config.nix";
    in
    {
      nixosConfigurations.normandy = coolNixosSystem {
        system = "x86_64-linux";
        modules = [
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

      nixosConfigurations.elbrus = nixpkgsTweaks.lib.nixosSystem {
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

      hydraJobs.build.normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
      hydraJobs.build.normandyTest = self.nixosConfigurations.normandyTest.config.system.build.toplevel;
      ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
        flake = self;
        systems = [ "x86_64-linux" ];
      };
    };
}
