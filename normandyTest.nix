# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "normandy"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

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

  nixpkgs.overlays = let badstdenv = (import pkgs.path { system = "x86_64-linux"; }).stdenv;
  #nixpkgs.overlays = let badstdenv = pkgs.gccStdenv;
  in [(self: super: rec {
    python38 = super.python38.override { enableOptimizations = false; };
    python3 = python38;
    python27 = super.python27.override { enableOptimizations = false; };
    python2 = python27;
    python = python27;
    python38Packages = pkgs.lib.recurseIntoAttrs python38.pkgs;

    # God damn llvm linking errors can't find standard library junk :(
    rust_1_45 = super.rust_1_45.override {stdenv = badstdenv; };
    rust_1_53 = super.rust_1_53.override {stdenv = badstdenv; };
    rust = rust_1_53;
    rustPackages_1_45 = rust_1_45.packages.stable;
    rustPackages_1_53 = rust_1_53.packages.stable;
    rustPackages = rustPackages_1_53;
    inherit (rustPackages) cargo clippy rustc rustPlatform;

    # LLVM crash :(
    valgrind = super.valgrind.override {stdenv = badstdenv; };
    nftables = super.nftables.override {stdenv = badstdenv; };
    speex = super.speex.override {stdenv = badstdenv; };
    
    # Not being built?
    #tpm2-tools = super.tpm2-tools.override {stdenv = badstdenv; };
    fwupd = super.fwupd.override {stdenv = badstdenv; };
    
    # Command gcc not found
    mbrola = super.mbrola.override {stdenv = badstdenv; };
    ostree = super.ostree.override {stdenv = badstdenv; };
    transfig = super.transfig.override {stdenv = badstdenv; };
    iproute2 = super.iproute2.override {stdenv = badstdenv; };
    busybox = super.busybox.override {stdenv = badstdenv; };
    
    # Extra warnings
    keyutils = super.keyutils.override {stdenv = badstdenv; };
    accountsservice = super.accountsservice.override {stdenv = badstdenv; };
    networkmanager-sstp = super.networkmanager-sstp.override {stdenv = badstdenv; };
    libblockdev = super.libblockdev.override {stdenv = badstdenv; };
    brltty = super.brltty.override {stdenv = badstdenv; };
    dhcp = super.dhcp.override {stdenv = badstdenv; };
    dmraid = super.dmraid.override {stdenv = badstdenv; };

    # Multiple definiton
    cdrkit = super.cdrkit.override {stdenv = badstdenv; };
    strongswan = super.strongswan.override {stdenv = badstdenv; };
    kexectools = super.kexectools.override {stdenv = badstdenv; };
    gpm = super.gpm.override {stdenv = badstdenv; };
    cpio = super.cpio.override {stdenv = badstdenv; };
    sharutils = super.sharutils.override { stdenv = badstdenv; };

    # omp stuff missing?
    openblas = super.openblas.override {stdenv = badstdenv; };
    suitesparse = super.suitesparse.override {stdenv = badstdenv; };

    # Confirmed weird to be investigated further
    hercules-ci-agent = super.hercules-ci-agent.override {stdenv = badstdenv; };
    efibootmgr = super.efibootmgr.override {stdenv = badstdenv; };
    elfutils = super.elfutils.override {stdenv = badstdenv; };
    glibcLocales = super.glibcLocales.override {stdenv = badstdenv; };
    cyrus_sasl = super.cyrus_sasl.override {stdenv = badstdenv; };
    libomxil-bellagio = super.libomxil-bellagio.override {stdenv = badstdenv; };
    avahi = super.avahi.override { stdenv = badstdenv; };
    libdc1394 = super.libdc1394.override {stdenv = badstdenv; };
    directfb = super.directfb.override {stdenv = badstdenv; };
    bluez5 = super.bluez5.override {stdenv = badstdenv; };
    ppp = super.ppp.override {stdenv = badstdenv; };
    unittest-cpp = super.unittest-cpp.override {stdenv = badstdenv; };
    libnma = super.libnma.override {stdenv = badstdenv; };
    openjdk8 = super.openjdk8.override {stdenv = badstdenv; };
    postgresql_11 = super.postgresql_11.override {stdenv = badstdenv; };
    poppler = super.poppler.override {stdenv = badstdenv; };
    groff = super.groff.override {stdenv = badstdenv; };
    ell = super.ell.override {stdenv = badstdenv; };
    gnome = super.gnome.overrideScope' (
      selfx: superx: {
        gnome-color-manager = superx.gnome-color-manager.override{ stdenv = badstdenv; };
      }
    );
    gst_all_1 = super.gst_all_1 // { gst-plugins-bad = super.gst_all_1.gst-plugins-bad.override {stdenv = badstdenv; }; };
  })];

  
  nixpkgs.config.replaceStdenv = { pkgs }: pkgs.llvmPackages_13.stdenv;

  environment.systemPackages = with pkgs; [
    wget vim
 #   gnome3.gnome-tweak-tool
    file
    git
    htop
    ripgrep
    fend
    zsh
  ];
  
  services.sshd.enable = true;

#   programs.steam.enable = false;

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;

  #services.hercules-ci-agent.enable = true;
  #services.hercules-ci-agent.settings.concurrentTasks = 32;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 3000 ];
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
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICwWm3Yv/f8pmUfZIm8SvsbrewsNcpUHpJ3zrODSt/0 rhys@tempest" ];
  };

  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000"; # externally visible URL
    notificationSender = "hydra@localhost"; # e-mail of hydra service
    # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
    buildMachinesFiles = [];
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };
  
  nix.buildMachines = [
    { hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 32;
    }
  ];

}

