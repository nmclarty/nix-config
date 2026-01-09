{ flake, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    nixos.server
    # standalone
    disko.default
    disko.single
  ];

  # hardware
  networking = {
    hostName = "timberhearth";
    hostId = "41bc3559";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };
  disko.devices.disk.primary.device = "/dev/sda";
}
