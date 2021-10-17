# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./elbrus-hardware-configuration.nix
      ./nix-conf.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;
  boot.plymouth.theme = "solar";

  networking.hostName = "elbrus"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.enp0s31f6.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    wget vim
    gnome.gnome-tweak-tool
    gnome.gnome-boxes
    file
    git
    htop
    ripgrep
    fend
    virt-manager
    virt-viewer
    exa
    python3
    keepassx
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuRunAsRoot = false;
    extraConfig = ''
    memory_backing_dir = "/dev/shm/"
    '';
  };
  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
    "i915-GVTg_V5_8" = {
      uuid = [ "f471a88a-c8b1-4ab5-9444-1e57f012eb55" ];
    };
  };
  
  # services.sshd.enable = true;

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  programs.chromium.enable = true;
  programs.chromium.extraOpts = {
    "BrowserSignin" = 0;
    "SyncDisabled" = true;
    "PasswordManagerEnabled" = false;
    "ExtensionInstallBlocklist" = "*";
  };
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  networking.firewall = {
    enable = true;
    logRefusedPackets = true;
    interfaces.virbr0 = {
      allowedTCPPorts = [ 5656 ];
    };
    interfaces.virbr1 = {
      allowedTCPPorts = [ 8000 ];
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  users.users.rhys = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/rhys";
    description = "Rhys Davies";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "libvirtd" "networkmanager" ];
  };
  
  nix.buildMachines = [
    { hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 4;
    }
  ];

}

