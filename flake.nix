{
  inputs = {
    nixpkgsTweaks.url = "github:rhysmdnz/nixpkgs/my-tweaks";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
  };

  outputs = { self, nixpkgs, nixpkgsTweaks, flake-compat-ci, ... }: {

    nixosConfigurations.normandy = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./normandy.nix ];
    };

    nixosConfigurations.normandyTest = nixpkgsTweaks.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./normandyTest.nix ];
    };
    
    hydraJobs.build.normandy = self.nixosConfigurations.normandy.config.system.build.toplevel;
    hydraJobs.build.normandyTest = self.nixosConfigurations.normandyTest.config.system.build.toplevel;
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;
      systems = [ "x86_64-linux" ];
    };
  };
}
