{ flake, pkgs, lib, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    nixos.server
    # disko
    disko.default
    disko.sbc
    # host
    ./ups.nix
  ];

  # the backup service requires ZFS, so disable it
  services = {
    py-backup.enable = lib.mkForce false;
    sanoid.enable = lib.mkForce false;
  };

  # hardware
  networking = {
    hostName = "timberhearth";
    hostId = "c8cdbbba";
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  boot = {
    # lts kernel lacks support for many rock 5b features
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "nvme" "usbhid" "usb_storage" "sr_mod" ];
  };
  disko.devices.disk.primary.device = "/dev/nvme0n1";
}
