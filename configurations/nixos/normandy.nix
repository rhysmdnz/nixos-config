{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

{
  imports = [
    ../../nix-conf.nix
    flake.inputs.lanzaboote.nixosModules.lanzaboote
    flake.inputs.nix-index-database.nixosModules.nix-index
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "normandy";

  home-manager.users.rhys.imports = [ ../../home.nix ];

  boot.initrd.systemd.enable = true;

  boot.tmp.cleanOnBoot = true;

  hardware.steam-hardware.enable = true;
  #hardware.xone.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.resolved.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.sauce-code-pro ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  services.flatpak.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  security.tpm2.enable = true;

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

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    qemu.swtpm.enable = true;
    extraConfig = ''
      memory_backing_dir = "/dev/shm/"
    '';
  };
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];

  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 32;

  virtualisation.podman.enable = true;
  services.tailscale.enable = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

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

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "tpm_crb"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/893b99e5-e698-4683-87bc-27d06b9db814";
      preLVM = true;
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0a6aff31-5c31-4b6f-b6c9-061cd045e6bd";
    fsType = "btrfs";
    options = [ "subvol=nixos-root" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B8DB-8587";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/8e9289ef-3723-433c-90fd-e7fb92035f20"; } ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
