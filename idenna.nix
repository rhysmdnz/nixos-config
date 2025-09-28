{ config, pkgs, ... }:

{
  imports = [
    ./nix-conf.nix
  ];

  users.users.rhys = {
    name = "rhys";
    home = "/Users/rhys";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    fend
    nixpkgs-fmt
    # binwalk
    fd
    gh
    git
    jq
    poetry
    pwgen
    ripgrep
    rustup
    nixd
    nixfmt-rfc-style
  ];

  # Auto upgrade nix package and the daemon service.
  nix.enable = true;

  programs.nix-index.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  security.pam.services.sudo_local.touchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
