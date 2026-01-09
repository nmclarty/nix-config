{ flake, inputs, config, pkgs, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    nixos.server
    nixos.apps
    # disko
    disko.default
    disko.mirror
    disko.cold
    # host
    ./samba.nix
    ./backup.nix
  ];

  # hardware
  networking = {
    hostName = "ashtwin";
    hostId = "43c12ddf";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" "i2c-dev" ];
  };
  disko.devices.disk = {
    primary.device = "/dev/nvme0n1";
    secondary.device = "/dev/nvme1n1";
  };

  # extra zpool
  sops.secrets."zfs/cold".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  services.sanoid.datasets.cold = {
    useTemplate = [ "default" ];
    recursive = true;
  };

  # lights
  environment.systemPackages = with pkgs; [ i2c-tools ugreen-leds-cli ];
  systemd.services.ugreen-leds = {
    enable = true;
    wantedBy = [ "default.target" ];
    description = "Control system leds on startup";
    path = with pkgs; [
      ugreen-leds-cli
      i2c-tools
    ];
    script = ''
      set -euo pipefail
      ugreen_leds_cli all -off
      echo "Turned off all system leds"
    '';
  };

  # apps
  # apps.garage.enable = true;
}
