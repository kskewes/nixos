{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "rpool-tl/snap/root";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/380F-3D2B";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "rpool-tl/nosnap/nix";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containers" = {
    device = "rpool-tl/nosnap/containers";
    fsType = "zfs";
  };

  fileSystems."/var/lib/docker" = {
    device = "rpool-tl/nosnap/docker";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt" = {
    device = "rpool-tl/nosnap/libvirt";
    fsType = "zfs";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/67ddceaa-2d57-487d-8f31-41ba0f24c520"; }];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
