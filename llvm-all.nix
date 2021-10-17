{ config, pkgs, ... }:

{
  nixpkgs.overlays = let badstdenv = (import pkgs.path { system = "x86_64-linux"; }).stdenv;
  in [(self: super: rec {
    python38 = super.python38.override { enableOptimizations = false; };
    python3 = python38;
    python27 = super.python27.override { enableOptimizations = false; };
    python2 = python27;
    python = python27;
    python38Packages = pkgs.lib.recurseIntoAttrs python38.pkgs;

    # God damn llvm linking errors can't find standard library junk :(
    rust_1_45 = super.rust_1_45.override {stdenv = badstdenv; };
    rust_1_55 = super.rust_1_55.override {stdenv = badstdenv; };
    rust = rust_1_55;
    rustPackages_1_45 = rust_1_45.packages.stable;
    rustPackages_1_55 = rust_1_55.packages.stable;
    rustPackages = rustPackages_1_55;
    inherit (rustPackages) cargo clippy rustc rustPlatform;
    
    # Not being built?
    #tpm2-tools = super.tpm2-tools.override {stdenv = badstdenv; };
    fwupd = super.fwupd.override {stdenv = badstdenv; };
    
    # Command gcc not found
    mbrola = super.mbrola.override {stdenv = badstdenv; };
    ostree = super.ostree.override {stdenv = badstdenv; };
    transfig = super.transfig.override {stdenv = badstdenv; };
    iproute2 = super.iproute2.override {stdenv = badstdenv; };
    busybox = super.busybox.override {stdenv = badstdenv; };
    boost-build = super.boost-build.override {stdenv = badstdenv; };
    
    # Extra warnings
    keyutils = super.keyutils.override {stdenv = badstdenv; };
    accountsservice = super.accountsservice.override {stdenv = badstdenv; };
    networkmanager-sstp = super.networkmanager-sstp.override {stdenv = badstdenv; };
    libblockdev = super.libblockdev.override {stdenv = badstdenv; };
    brltty = super.brltty.override {stdenv = badstdenv; };
    dhcp = super.dhcp.override {stdenv = badstdenv; };
    dmraid = super.dmraid.override {stdenv = badstdenv; };

    # omp stuff missing?
    openblas = super.openblas.override {stdenv = badstdenv; };
    suitesparse = super.suitesparse.override {stdenv = badstdenv; };

    # Confirmed weird to be investigated further
    valgrind = super.valgrind.override {stdenv = badstdenv; };
    valgrind-light = valgrind.override { gdb = null; };
    ncurses = super.ncurses.override {stdenv = badstdenv; };
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
}

