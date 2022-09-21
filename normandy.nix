# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nix-conf.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.secureboot = {
    enable = true;
    signingKeyPath = "/path/to/the/signing/key";
    signingCertPath = "/path/to/the/signing/cert";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  hardware.steam-hardware.enable = true;
  hardware.xone.enable = true;
  
  networking.hostName = "normandy"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp0s31f6.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };


  nixpkgs.overlays = [
    (self: super: {
      nvidia-x11 = super.nvidia-x11.override { disable32Bit = true; };
    })
  ];

  environment.systemPackages = with pkgs; [
    wget
    vim
    gnome.gnome-tweaks
    virt-manager
    file
    git
    htop
    ripgrep
    fend
    python3
    exa
    gparted
    ntfs3g
  ];

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 32;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  users.users.rhys = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/rhys";
    description = "Rhys Davies";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "libvirtd" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICwWm3Yv/f8pmUfZIm8SvsbrewsNcpUHpJ3zrODSt/0 rhys@tempest"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCY3oqsIGMbxTT3Ehh4iVyIbrmzXzKasaUrLcfhcBwhCagQ2M6ykW9FO6K6gMP/5xYZMC0Lw/ycjN0fefhGUaNA= Idenna@secretive.Idenna.local"
    ];
  };
  users.users.jamie = {
    uid = 1001;
    isNormalUser = true;
    home = "/home/jamie";
    description = "Jamie";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpDBWqUFKaNthEoVRjNa5GWnrzVQRZsKBczsYM++B7F root@nixos" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmjgKWGrFYlHDY67GEaOhH32DgxbucL/XNlSROXQjWU hydra@hydra" ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.swtpm.enable = true;
    extraConfig = ''
      memory_backing_dir = "/dev/shm/"
    '';
  };

  nix.settings.trusted-users = [ "jamie" ];
  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 32;
    }
  ];

}

