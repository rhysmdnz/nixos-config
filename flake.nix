{
  inputs = {
    nixpkgsTweaks.url = "github:rhysmdnz/nixpkgs/my-tweaks";
    nixpkgsHardened.url = "github:rhysmdnz/nixpkgs/hardening";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
    home-manager.url = "github:nix-community/home-manager";
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/develop";
    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, nixpkgsHardened, nixpkgsTweaks, flake-compat-ci, home-manager, nix-doom-emacs, emacs, ... }: {

    nixosConfigurations.normandy = nixpkgs.lib.nixosSystem {
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

    nixosConfigurations.normandyTest = nixpkgsHardened.lib.nixosSystem {
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

    hydraJobs.build.normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
    hydraJobs.build.normandyTest = self.nixosConfigurations.normandyTest.config.system.build.toplevel;
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;
      systems = [ "x86_64-linux" ];
    };
  };
}
