# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "rpool-asus/snap/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool-asus/nosnap/nix";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containers" = {
    device = "rpool-asus/nosnap/containers";
    fsType = "zfs";
  };

  fileSystems."/var/lib/docker" = {
    device = "rpool-asus/nosnap/docker";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6D29-2988";
    fsType = "vfat";
  };

  swapDevices = [{
    device =
      "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21GNXAGA03282Z-part2";
  }];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
