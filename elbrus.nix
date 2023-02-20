{ config, pkgs, lib, ... }:

{

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "solar";

  networking.hostName = "elbrus";

  environment.systemPackages = with pkgs; [
    microsoft-edge
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


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "tpm_tis" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.lvm.boot.thin.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/784ad5d8-4807-4a72-948a-876e32f83c49";
      preLVM = true;
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/933ef0e3-bc3b-466c-ad3b-66302d439f0e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/8AA7-64F6";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/638528b1-a315-47c3-93c4-619eddaf89bb"; }];

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

}

