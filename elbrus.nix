{
  config,
  pkgs,
  lib,
  ...
}:

let
  ivsc-firmware =
    with pkgs;
    stdenv.mkDerivation {
      pname = "ivsc-firmware";
      version = "main";

      src = pkgs.fetchFromGitHub {
        owner = "intel";
        repo = "ivsc-firmware";
        rev = "10c214fea5560060d387fbd2fb8a1af329cb6232";
        sha256 = "sha256-kEoA0yeGXuuB+jlMIhNm+SBljH+Ru7zt3PzGb+EPBPw=";

      };

      installPhase = ''
        mkdir -p $out/lib/firmware/vsc/soc_a1_prod

        cp firmware/ivsc_pkg_ovti01a0_0.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_pkg_ovti01a0_0_a1_prod.bin
        cp firmware/ivsc_skucfg_ovti01a0_0_1.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_skucfg_ovti01a0_0_1_a1_prod.bin
        cp firmware/ivsc_fw.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_fw_a1_prod.bin
      '';
    };
in
{

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.plymouth.enable = true;
  #boot.plymouth.theme = "solar";
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "elbrus";

  environment.systemPackages = with pkgs; [
    rustup
    clang
    vscode
    gnumake
    openssl
    virtiofsd
    #qemu
    awscli2
    ssm-session-manager-plugin
  ];

  programs.chromium.enable = true;
  programs.chromium.extraOpts = {
    "BrowserSignin" = 0;
    "SyncDisabled" = true;
    "PasswordManagerEnabled" = false;
    "ExtensionInstallBlocklist" = "*";
  };

  virtualisation.podman.enable = true;

  networking.firewall = {
    enable = true;
    logRefusedPackets = true;
    interfaces.virbr0 = {
      allowedTCPPorts = [
        5656
        5657
      ];
    };
    interfaces.virbr1 = {
      allowedTCPPorts = [ 8000 ];
    };
  };

  services.intune = {
    enable = true;
  };

  services.fprintd.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "vmd"
    "nvme"
    "usb_storage"
    "sd_mod"
    "tpm_tis"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.lvm.boot.thin.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e7734748-b2ac-4362-b363-bca3e83ad246";
      preLVM = true;
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
      bypassWorkqueues = true;
    };
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/933ef0e3-bc3b-466c-ad3b-66302d439f0e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/29A3-03ED";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/0df7c43a-4fe7-4f4a-b54e-acdf930a289a";
      randomEncryption.enable = true;
      randomEncryption.allowDiscards = true;
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.ipu6.enable = true;
  hardware.ipu6.platform = "ipu6ep";
  boot.extraModprobeConfig = "options v4l2loopback nr_devices=0";
  hardware.firmware = [
    ivsc-firmware
    pkgs.sof-firmware
  ];

  #services.usbguard.enable = true;
  #services.usbguard.dbus.enable = true;
  services.usbguard.rules = ''
    allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0002 serial "0000:00:0d.0" name "xHCI Host Controller" hash "d3YN7OD60Ggqc9hClW0/al6tlFEshidDnQKzZRRk410=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
    allow id 1d6b:0003 serial "0000:00:0d.0" name "xHCI Host Controller" hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
    allow id 0bda:5483 serial "" name "4-Port USB 2.0 Hub" hash "k3gFsmbvSmPG7L6+9Dg/tpZHJ5ZB6AEAs0F27wvAUPc=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-1" with-interface { 09:00:01 09:00:02 } with-connect-type "hotplug"
    allow id 8086:0b63 serial "" name "USB Bridge" hash "FS+5wGsDrfrGjZOaSqsP6eURrwK0c8CPfCnuJxvuyEI=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-7" with-interface ff:ff:ff with-connect-type "not used"
    allow id 27c6:63cc serial "UIDCE9C7568_XXXX_MOC_B0" name "Goodix USB2.0 MISC" hash "Wm28DQ/nvUI0+lqEk5/E5epbrEYVVjNmxpYRKLwK7m0=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface ff:00:00 with-connect-type "hardwired"
    allow id 0bda:0483 serial "" name "4-Port USB 3.0 Hub" hash "efK4gkHTTeiKf6LfLdYZEZG2TYFf13wA0+3iP0sbx8Y=" parent-hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" via-port "4-4" with-interface 09:00:00 with-connect-type "hotplug"
    allow id 8087:0033 serial "" name "" hash "ciwwGozaSw4maEXfs4NdvETeMt6bnFEK6f4vmCqfud0=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"
    allow id 0bda:5483 serial "" name "4-Port USB 2.0 Hub" hash "R/Tn+DhBNQttJurQBBlK0EtGrx6voTbEoFsGDlwS864=" parent-hash "k3gFsmbvSmPG7L6+9Dg/tpZHJ5ZB6AEAs0F27wvAUPc=" via-port "1-1.1" with-interface { 09:00:01 09:00:02 } with-connect-type "unknown"
    allow id 0bda:0483 serial "" name "4-Port USB 3.0 Hub" hash "PRCSPlCO+VLr5H9eAN/IDMC8Dmdht2t6mw9lDBIFIFY=" parent-hash "efK4gkHTTeiKf6LfLdYZEZG2TYFf13wA0+3iP0sbx8Y=" via-port "4-4.1" with-interface 09:00:00 with-connect-type "unknown"
    allow id 0bda:8153 serial "001000001" name "USB 10/100/1000 LAN" hash "y8c/mp5bRTGXYVTDuNzIBwhRaTbSU30I2rp5Y7ZfR8o=" parent-hash "PRCSPlCO+VLr5H9eAN/IDMC8Dmdht2t6mw9lDBIFIFY=" with-interface { ff:ff:00 02:06:00 0a:00:00 0a:00:00 } with-connect-type "unknown"
    allow with-interface one-of { 03:00:01 03:01:01 03:00:02 03:01:02 }
  '';

  security.polkit.extraConfig = ''
    // Allow users in wheel group to communicate with USBGuard
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.usbguard.Policy1.listRules" ||
             action.id == "org.usbguard.Policy1.appendRule" ||
             action.id == "org.usbguard.Policy1.removeRule" ||
             action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
             action.id == "org.usbguard.Devices1.listDevices" ||
             action.id == "org.usbguard1.getParameter" ||
             action.id == "org.usbguard1.setParameter") &&
            subject.active == true && subject.local == true &&
            subject.isInGroup("wheel")) {
                return polkit.Result.YES;
        }
    });
  '';

  programs.dconf.profiles.gdm.databases = [
    {
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      settings."org/gnome/login-screen".enable-fingerprint-authentication = false;
    }
  ];

  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.dockerCompat = true;
  programs.gnupg.agent.enable = true;

}
