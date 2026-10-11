{
  lib,
  pkgs,
  flake,
  ...
}:

{
  imports = [
    ../../../nix-conf.nix
    ./hardware.nix
    flake.inputs.lanzaboote.nixosModules.lanzaboote
    flake.inputs.nix-index-database.nixosModules.nix-index
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "normandy";

  home-manager.users.rhys.imports = [ ../../../home.nix ];

  boot = {
    initrd.systemd.enable = true;
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = false;
    loader.efi.canTouchEfiVariables = true;
    #bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  hardware = {
    steam-hardware.enable = true;
    #xone.enable = true;

    graphics.enable = true;
    nvidia.open = true;
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    resolved.enable = true;
    printing.enable = true;
    flatpak.enable = true;
    tailscale.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable the X11 windowing system.
    xserver.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    openssh.settings.PasswordAuthentication = false;

    hercules-ci-agent.enable = true;
    hercules-ci-agent.settings.concurrentTasks = 32;

    nscd.enable = false;
  };

  system.nssModules = lib.mkForce [ ];

  security.rtkit.enable = true;
  security.tpm2.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.sauce-code-pro ];

  environment.systemPackages = with pkgs; [
    wget
    vim
    gnome-tweaks
    gnome-boxes
    virt-manager
    virt-viewer
    file
    git
    htop
    ripgrep
    fend
    python3
    gparted
    ntfs3g
    deja-dup
    thin-provisioning-tools
    uv
    ruff
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    nix-index.enable = true;
    command-not-found.enable = false;
    zsh.enable = true;
    zsh.enableCompletion = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
      qemu.swtpm.enable = true;
      extraConfig = ''
        memory_backing_dir = "/dev/shm/"
      '';
    };
    spiceUSBRedirection.enable = true;
    podman.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.rhys = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/rhys";
    description = "Rhys Davies";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "libvirtd"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICwWm3Yv/f8pmUfZIm8SvsbrewsNcpUHpJ3zrODSt/0 rhys@tempest"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCY3oqsIGMbxTT3Ehh4iVyIbrmzXzKasaUrLcfhcBwhCagQ2M6ykW9FO6K6gMP/5xYZMC0Lw/ycjN0fefhGUaNA= Idenna@secretive.Idenna.local"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAMZS589Z0qVbne7FZnxx0I/0Va3Y/uAVs1Q/2bM8fv7kDZgYeKWfWHp5DTxlpSIqnR60ZUJXLNk0zZONC23sIs= datapad"
    ];
  };

  users.users.jamie = {
    uid = 1001;
    isNormalUser = true;
    home = "/home/jamie";
    description = "Jamie";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpDBWqUFKaNthEoVRjNa5GWnrzVQRZsKBczsYM++B7F root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmjgKWGrFYlHDY67GEaOhH32DgxbucL/XNlSROXQjWU hydra@hydra"
    ];
  };

  nix.settings.trusted-users = [ "jamie" ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
