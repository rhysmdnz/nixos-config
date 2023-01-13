{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./nix-conf.nix
    ];

  boot.initrd.systemd.enable = true;

  hardware.steam-hardware.enable = true;
  hardware.xone.enable = true;

  services.fstrim.enable = true;
  services.hardware.openrgb.enable = false;
  services.fwupd.enable = true;
  services.resolved.enable = true;

  #security.rtkit.enable = true;
  #hardware.pulseaudio.enable = false;
  #services.pipewire =
  #  {
  #    enable = true;
  #    alsa.enable = true;
  #    alsa.support32Bit = true;
  #    pulse.enable = true;
  #  };


  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    gnome.gnome-tweaks
    gnome.gnome-boxes
    virt-manager
    virt-viewer
    file
    git
    htop
    ripgrep
    fend
    python3
    exa
    gparted
    ntfs3g
    deja-dup
    thin-provisioning-tools
  ];

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  security.tpm2.enable = true;

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

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.swtpm.enable = true;
    extraConfig = ''
      memory_backing_dir = "/dev/shm/"
    '';
  };
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  nix.gc.automatic = true;
  nix.gc.options = "-d";
  nix.settings.auto-optimise-store = true;

  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];

  hardware.enableRedistributableFirmware = true;
}
