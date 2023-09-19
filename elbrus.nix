{ config, pkgs, lib, ... }:

{

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "solar";
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "elbrus";

  environment.systemPackages = with pkgs; [
    microsoft-edge
    rustup
    clang
    vscode
    gnumake
    openssl
    virtiofsd
    #qemu
  ];

  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
    "i915-GVTg_V5_8" = {
      uuid = [ "f471a88a-c8b1-4ab5-9444-1e57f012eb55" ];
    };
  };

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
      allowedTCPPorts = [ 5656 ];
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

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "tpm_tis" "rtsx_pci_sdmmc" ];
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
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/933ef0e3-bc3b-466c-ad3b-66302d439f0e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/29A3-03ED";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-partuuid/0df7c43a-4fe7-4f4a-b54e-acdf930a289a"; randomEncryption.enable = true; randomEncryption.allowDiscards = true; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl = {
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  hardware.ipu6.enable = true;
  hardware.ipu6.platform = "ipu6ep";

}
