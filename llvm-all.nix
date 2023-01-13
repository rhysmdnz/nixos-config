{ config, pkgs, ... }:


# Notes to self
# My GCC hacks mean it's linking with ld.bfd :(

{
  nixpkgs.overlays =
    let badstdenv = (import pkgs.path { system = "x86_64-linux"; }).stdenv;
    in
    [
      (self: super: rec {
        python310 = super.python310.override { enableOptimizations = false; };
        python3 = python310;
        python27 = super.python27.override { enableOptimizations = false; };
        python2 = python27;
        python = python27;
        python310Packages = pkgs.lib.recurseIntoAttrs python310.pkgs;

        # God damn llvm linking errors can't find standard library junk :(
        rust_1_45 = super.rust_1_45.override { stdenv = badstdenv; };
        rust_1_65 = super.rust_1_65.override { stdenv = badstdenv; };
        rust = rust_1_65;
        rustPackages_1_45 = rust_1_45.packages.stable;
        rustPackages_1_65 = rust_1_65.packages.stable;
        rustPackages = rustPackages_1_65;
        inherit (rustPackages) cargo clippy rustc rustPlatform;

	# disable tests
	pixman = super.pixman.overrideAttrs (finalAttrs: previousAttrs: {
		doCheck = false;
	});


	gnu-efi = super.gnu-efi.overrideAttrs (attrs: {
		patches = [./gnu-efi/clang.patch];
		makeFlags = attrs.makeFlags ++ ["CC=${super.buildPackages.stdenv.cc.targetPrefix}cc"];
	});


        # Not being built?
        #tpm2-tools = super.tpm2-tools.override {stdenv = badstdenv; };
        fwupd = super.fwupd.override { stdenv = badstdenv; };

        # Command gcc not found
        mbrola = super.mbrola.override { stdenv = badstdenv; };
        ostree = super.ostree.override { stdenv = badstdenv; };
        transfig = super.transfig.override { stdenv = badstdenv; };
        iproute2 = super.iproute2.override { stdenv = badstdenv; };
        busybox = super.busybox.override { stdenv = badstdenv; };
        boost-build = super.boost-build.override { stdenv = badstdenv; };
        yodl = super.yodl.override { stdenv = badstdenv; };
        fwupd-efi = super.fwupd-efi.override { stdenv = badstdenv; };
        efivar = super.efivar.override { stdenv = badstdenv; };

        # Extra warnings
        keyutils = super.keyutils.override { stdenv = badstdenv; };
        accountsservice = super.accountsservice.override { stdenv = badstdenv; };
        networkmanager-sstp = super.networkmanager-sstp.override { stdenv = badstdenv; };
        libblockdev = super.libblockdev.override { stdenv = badstdenv; };
        brltty = super.brltty.override { stdenv = badstdenv; };
        dhcp = super.dhcp.override { stdenv = badstdenv; };
        dmraid = super.dmraid.override { stdenv = badstdenv; };
        sbsigntool = super.sbsigntool.override { stdenv = badstdenv; };
        nfs-utils = super.nfs-utils.override { stdenv = badstdenv; };
        edk2 = super.edk2.override { stdenv = badstdenv; };
        seabios = super.seabios.override { stdenv = badstdenv; };

        # omp stuff missing?
        openblas = super.openblas.override { stdenv = badstdenv; };
        suitesparse = super.suitesparse.override { stdenv = badstdenv; };

        # Confirmed weird to be investigated further
        gdb = super.gdb.override { stdenv = badstdenv; };
        valgrind = super.valgrind.override { stdenv = badstdenv; };
        valgrind-light = valgrind.override { gdb = null; };
        ncurses = super.ncurses.override { stdenv = badstdenv; };
        efibootmgr = super.efibootmgr.override { stdenv = badstdenv; };
        elfutils = super.elfutils.override { stdenv = badstdenv; };
        glibcLocales = super.callPackage (super.path + "/pkgs/development/libraries/glibc/locales.nix") { stdenv = badstdenv; };
        glibcLocalesUtf8 = super.callPackage (super.path + "/pkgs/development/libraries/glibc/locales.nix") { stdenv = badstdenv; allLocales = false; };
        cyrus_sasl = super.cyrus_sasl.override { stdenv = badstdenv; };
        libomxil-bellagio = super.libomxil-bellagio.override { stdenv = badstdenv; };
        avahi = super.avahi.override { stdenv = badstdenv; };
        libdc1394 = super.libdc1394.override { stdenv = badstdenv; };
        directfb = super.directfb.override { stdenv = badstdenv; };
        bluez5 = super.bluez5.override { stdenv = badstdenv; };
        ppp = super.ppp.override { stdenv = badstdenv; };
        unittest-cpp = super.unittest-cpp.override { stdenv = badstdenv; };
        libnma = super.libnma.override { stdenv = badstdenv; };
        openjdk8 = super.openjdk8.override { stdenv = badstdenv; };
        postgresql_11 = super.postgresql_11.override { stdenv = badstdenv; };
        poppler = super.poppler.override { stdenv = badstdenv; };
        groff = super.groff.override { stdenv = badstdenv; };
        ell = super.ell.override { stdenv = badstdenv; };
        gnome = super.gnome.overrideScope' (
          selfx: superx: {
            gnome-color-manager = superx.gnome-color-manager.override { stdenv = badstdenv; };
          }
        );
        gst_all_1 = super.gst_all_1 // { gst-plugins-bad = super.gst_all_1.gst-plugins-bad.override { stdenv = badstdenv; }; };
        libapparmor = super.libapparmor.override { stdenv = badstdenv; };
        #systemd = super.systemd.override { stdenv = badstdenv; };
        #openssl_3 = super.openssl_3.override { stdenv = badstdenv; };
        #openssl = super.openssl.override { stdenv = badstdenv; };
        jemalloc = super.jemalloc.override { stdenv = badstdenv; };
        acpica-tools = super.acpica-tools.override { stdenv = badstdenv; };
        libclc = super.libclc.override { stdenv = badstdenv; };
        #libssh2 = super.libssh2.override { stdenv = badstdenv; };
        ffmpeg = super.ffmpeg.override { stdenv = badstdenv; };
        ffmpeg_4 = super.ffmpeg_4.override { stdenv = badstdenv; };
        ffmpeg-headless = super.ffmpeg-headless.override { stdenv = badstdenv; };
        ffmpeg_4-headless = super.ffmpeg_4-headless.override { stdenv = badstdenv; };
        udisks2 = super.udisks2.override { stdenv = badstdenv; };
        udisks = super.udisks.override { stdenv = badstdenv; };
        OVMFFull = super.OVMFFull.override { stdenv = badstdenv; };
        nss = super.nss.override { stdenv = badstdenv; };


       webkitgtk_4_1 = super.webkitgtk_4_1.override { stdenv = badstdenv; };
       webkitgtk_5_0 = super.webkitgtk_5_0.override { stdenv = badstdenv; };
      
      })
    ];


  nixpkgs.config.replaceStdenv = { pkgs }: pkgs.llvmPackages_14.stdenv;
}

