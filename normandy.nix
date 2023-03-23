{ config, pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "normandy";

  services.xserver.videoDrivers = [ "nvidia" ];

  nixpkgs.overlays = [
    (self: super: {
      nvidia-x11 = super.nvidia-x11.override { disable32Bit = true; };
    })
  ];

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
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpDBWqUFKaNthEoVRjNa5GWnrzVQRZsKBczsYM++B7F root@nixos" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmjgKWGrFYlHDY67GEaOhH32DgxbucL/XNlSROXQjWU hydra@hydra" ];
  };

  nix.settings.trusted-users = [ "jamie" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "tpm_crb" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  hardware.nvidia.modesetting.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/893b99e5-e698-4683-87bc-27d06b9db814";
      preLVM = true;
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0a6aff31-5c31-4b6f-b6c9-061cd045e6bd";
      fsType = "btrfs";
      options = [ "subvol=nixos-root" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/B8DB-8587";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c1ef00a9-228b-4010-978f-26f1864714bb"; }];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

