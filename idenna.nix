{ config, pkgs, ... }:

{
  imports =
    [
      ./nix-conf.nix
    ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.rhys = {
    name = "rhys";
    home = "/Users/rhys";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    emacs
    fend
    nixpkgs-fmt
    binwalk
    fd
    gh
    git
    jq
    nodePackages.npm
    nodePackages.yarn
    poetry
    pwgen
    ripgrep
    rustup
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;


  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  security.pam.enableSudoTouchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
