# This is a PLACEHOLDER. Regenerate on the actual machine:
#   nixos-generate-config --show-hardware-config > hosts/newton/hardware-configuration.nix
# Then commit the real file.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # TODO: replace UUIDs with actual values from `blkid` on the machine
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/450e790e-175e-4c31-b6e4-0c6bfc83a268";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6AB6-C3D2";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
