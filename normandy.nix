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

  #nixpkgs.overlays = let badstdenv = (import pkgs.path { system = "x86_64-linux"; }).stdenv;
  ##nixpkgs.overlays = let badstdenv = pkgs.gccStdenv;
  #in [(self: super: rec {
  #  sharutils = super.sharutils.override { stdenv = badstdenv; };
  #  gdbm = super.gdbm.override { stdenv = badstdenv; };
  #  gnum4 = super.gnum4.override { stdenv = badstdenv; };
  #  #libunwind = super.libunwind.override { stdenv = badstdenv; };
  #  python38 = super.python38.override { enableOptimizations = false; };
  #  python3 = python38;
  #  python27 = super.python27.override { enableOptimizations = false; };
  #  python2 = python27;
  #  python = python27;
  #  python38Packages = pkgs.lib.recurseIntoAttrs python38.pkgs;
  #  #e2fsprogs = super.e2fsprogs.override { stdenv = badstdenv; libuuid = super.libuuid.override {stdenv = badstdenv;}; };
  #  #llvmPackages_5 = super.llvmPackages_5.override {stdenv = badstdenv; };
  #  #llvmPackages_6 = super.llvmPackages_6.override {stdenv = badstdenv; };
  #  #llvmPackages_7 = super.llvmPackages_7.override {stdenv = badstdenv; };
  #  #llvmPackages_8 = super.llvmPackages_8.override {stdenv = badstdenv; };
  #  #llvmPackages_9 = super.llvmPackages_9.override {stdenv = badstdenv; };
  #  #llvmPackages_10 = super.llvmPackages_10.override {stdenv = badstdenv; };
  #  crda = super.crda.override {stdenv = badstdenv; };
  #  #gnu-efi = super.gnu-efi.override {stdenv = badstdenv; };
  #  elfutils = super.elfutils.override {stdenv = badstdenv; zlib=super.zlib.override {stdenv = badstdenv;}; };
  #  glibcLocales = super.glibcLocales.override {stdenv = badstdenv; };
  #  cpio = super.cpio.override {stdenv = badstdenv; };
  #  busybox = super.busybox.override {stdenv = badstdenv; };
  #  #audit = super.audit.override {stdenv = super.llvmPackages_12.lldClang.stdenv; };
  #  linuxConfig = super.linuxConfig.override {stdenv = badstdenv; };
  #  gpm = super.gpm.override {stdenv = badstdenv; };
  #  inetutils = super.inetutils.override {stdenv = badstdenv; };
  #  kbd = super.kbd.override {stdenv = badstdenv; pam = super.pam.override {stdenv = badstdenv; }; check = super.check.override {stdenv = badstdenv; }; };
  #  kexectools = super.kexectools.override {stdenv = badstdenv; };
  #  cyrus_sasl = super.cyrus_sasl.override {stdenv = badstdenv; };
  #  efibootmgr = super.efibootmgr.override {stdenv = badstdenv; };
  #  jemalloc = super.jemalloc.override {stdenv = badstdenv; };
  #  libfaketime = super.libfaketime.override {stdenv = badstdenv; };
  #  #libnftnl = super.libnftnl.override {stdenv = badstdenv; };
  #  libomxil-bellagio = super.libomxil-bellagio.override {stdenv = badstdenv; };
  #  iproute = super.iproute.override {stdenv = badstdenv; };
  #  #libsepol = super.libsepol.override {stdenv = badstdenv; };
  #  #libsepol = super.libsepol.override {stdenv = super.llvmPackages_12.lldClang.stdenv; };
  #  #libselinux = super.libselinux.override {stdenv = badstdenv; pcre = super.pcre.override {stdenv = badstdenv;}; python3 = super.python3.override {stdenv = badstdenv;};};
  #  #libselinux = super.libselinux.override {stdenv = badstdenv; pcre = super.pcre.override {stdenv = badstdenv;}; enablePython = false;};
  #  argyllcms = super.argyllcms.override {stdenv = badstdenv; };
  #  keyutils = super.keyutils.override {stdenv = badstdenv; };
  #  #avahi = super.avahi.override { stdenv = badstdenv; };
  #  #avahi = super.avahi.override {stdenv = badstdenv; expat = super.expat.override {stdenv = badstdenv; }; dbus = super.dbus.override {stdenv = badstdenv; systemd = super.systemd.override {stdenv = badstdenv; libgcrypt = super.libgcrypt.override {stdenv =badstdenv; libgpgerror = super.libgpgerror.override {stdenv = badstdenv; }; }; libgpgerror = super.libgpgerror.override {stdenv = badstdenv; }; gnu-efi = super.gnu-efi.override {stdenv = badstdenv;}; xz = super.xz.override {stdenv = badstdenv;}; lz4 = super.lz4.override {stdenv =badstdenv;}; libcap = super.libcap.override {stdenv=badstdenv; pam = super.pam.override {stdenv = badstdenv;}; }; libseccomp = super.libseccomp.override {stdenv = badstdenv;}; util-linux = super.util-linuxMinimal.override {stdenv = badstdenv; pam = super.pam.override{stdenv = badstdenv;};}; }; }; }; #Stupid threadding stuff :(
  #  cups = super.cups.override { avahi = null; }; # avahi is bad :(
  #  #geoclue = super.geoclue.override { avahi = null; }; # avahi is bad :(
  #  #libnfs = super.libnfs.override { avahi = null; }; # avahi is bad :(
  #  #mod_dnssd = super.mod_dnssd.override { avahi = null; }; # avahi is bad :(
  #  #xrdp = super.xrdp.override { avahi = null; }; # avahi is bad :(
  #  #gvfs = super.gvfs.override { avahi = null; }; # avahi is bad :(
  #  #vulkan-headers = super.vulkan-headers.override { avahi = null; }; # avahi is bad :(
  #  #sane-backends = super.sane-backends.override { avahi = null; };
  #  dmraid = super.dmraid.override {stdenv = badstdenv; };
  #  grub2 = super.grub2.override {stdenv = badstdenv; };
  #  iproute2 = super.iproute2.override {stdenv = badstdenv; };
  #  libdc1394 = super.libdc1394.override {stdenv = badstdenv; };
  #  dhcp = super.dhcp.override {stdenv = badstdenv; };
  #  strongswan = super.strongswan.override {stdenv = badstdenv; };
  #  aws-c-common = super.aws-c-common.override {stdenv = badstdenv; };
  #  aws-c-cal = super.aws-c-cal.override {stdenv = badstdenv; };
  #  aws-c-io = super.aws-c-io.override {stdenv = badstdenv; };
  #  aws-c-event-stream = super.aws-c-event-stream.override {stdenv = badstdenv; };
  #  aws-checksums = super.aws-checksums.override {stdenv = badstdenv; };
  #  guile_1_8 = super.guile_1_8.override {stdenv = badstdenv; };
  #  #pixman = super.pixman.override {stdenv = badstdenv; };
  #  directfb = super.directfb.override {stdenv = badstdenv; };
  #  gmime = super.gmime.override {stdenv = badstdenv; };
  #  bluez5 = super.bluez5.override {stdenv = badstdenv; };
  #  brltty = super.brltty.override {stdenv = badstdenv; };
  #  gupnp_igd = super.gupnp_igd.override {stdenv = badstdenv; };
  #  libblockdev = super.libblockdev.override {stdenv = badstdenv; };
  #  lua5 = super.lua5.override {stdenv = badstdenv; };
  #  lua5_3 = super.lua5_3.override {stdenv = badstdenv; };
  #  mbrola = super.mbrola.override {stdenv = badstdenv; };
  #  #openalSoft = super.openalSoft.override {stdenv = badstdenv; };
  #  openblas = super.openblas.override {stdenv = badstdenv; };
  #  tpm2-tools = super.tpm2-tools.override {stdenv = badstdenv; };
  #  suitesparse = super.suitesparse.override {stdenv = badstdenv; };
  #  unittest-cpp = super.unittest-cpp.override {stdenv = badstdenv; };
  #  transfig = super.transfig.override {stdenv = badstdenv; };
  #  #rust_1_51 = super.rust_1_51.override{stdenv = badstdenv; };
  #  #rust = rust_1_51;
  #  #rustPackages_1_51 = rust_1_51.packages.stable;
  #  #rustPackages = rustPackages_1_51;
  #  accountsservice = super.accountsservice.override {stdenv = badstdenv; };
  #  fwupd = super.fwupd.override {stdenv = badstdenv; };
  #  libnma = super.libnma.override {stdenv = badstdenv; };
  #  ostree = super.ostree.override {stdenv = badstdenv; };
  #  udisks = super.udisks.override {stdenv = badstdenv; };
  #  udisks2 = super.udisks2.override {stdenv = badstdenv; };
  #  networkmanager-sstp = super.networkmanager-sstp.override {stdenv = badstdenv; };
  #  openjdk8 = super.openjdk8.override {stdenv = badstdenv; };
  #  poppler = super.poppler.override {stdenv = badstdenv; };
  #  postgresql_11 = super.postgresql_11.override {stdenv = badstdenv; };
  #  cdrkit = super.cdrkit.override {stdenv = badstdenv; };
  #  #zlib = super.zlib.override {stdenv = badstdenv; };
  #  folks = super.folks.override {stdenv = badstdenv; };
  #  groff = super.groff.override {stdenv = badstdenv; };
  #  lame = super.lame.override {stdenv = badstdenv; };
  #  gnome3 = super.gnome3.overrideScope' (
  #    selfx: superx: {
  #      gnome-color-manager = superx.gnome-color-manager.override{ stdenv = badstdenv; };
  #    }
  #  );
  #})];
  #nixpkgs.overlays = [(self: super: rec {
  #  flatpak = super.flatpak.overrideAttrs (old: rec {
  #    pname = "flatpak";
  #    version = "1.11.3";
  #    src = super.fetchurl {
  #      url = "https://github.com/flatpak/flatpak/releases/download/${version}/${pname}-${version}.tar.xz";
  #      sha256 = "1284ead93b42acaec511a1649cd64d0df3da851bab2e65cf004bc90828d16b6c";
  #    };
  #  });
  #})];

  
  #nixpkgs.config.replaceStdenv = { pkgs }: pkgs.llvmPackages_11.stdenv;

  environment.systemPackages = with pkgs; [
    wget vim
    gnome3.gnome-tweak-tool
    file
    git
    htop
    ripgrep
    fend
  ];
  
  services.sshd.enable = true;

  # programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;

  services.hercules-ci-agent.enable = true;

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
  networking.firewall.allowedTCPPorts = [ 22 3000 43089 63333 ];
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
      builders-use-substitutes = true
    '';
   };
  nix.distributedBuilds = true;
  
  nix.buildMachines = [
    { hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 32;
    }
  ];

}

