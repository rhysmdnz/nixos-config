{
  config,
  lib,
  ...
}:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "tpm_crb"
      ];
      kernelModules = [ "dm-snapshot" ];

      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/893b99e5-e698-4683-87bc-27d06b9db814";
          preLVM = true;
          allowDiscards = true;
          crypttabExtraOpts = [ "tpm2-device=auto" ];
        };
      };
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
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

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
