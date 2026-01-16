{ inputs, config, flake, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    nixos.server
    nixos.apps
    nixos.extra-lanzaboote
    # disko
    disko.default
    disko.mirror
  ];

  # hardware
  networking = {
    hostName = "brittlehollow";
    hostId = "012580f6";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };
  disko.devices.disk = {
    primary.device = "/dev/nvme0n1";
    secondary.device = "/dev/nvme1n1";
  };

  # extra zpool
  sops.secrets."zfs/tank".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  boot.zfs.extraPools = [ "tank" ];
  services.sanoid.datasets.tank = {
    useTemplate = [ "default" ];
    recursive = true;
  };

  # apps
  apps = {
    # settings
    settings.cpus = "12-19";

    # apps
    immich.enable = true;
    seafile.enable = true;
    traefik.enable = true;
    pocket.enable = true;
    tinyauth.enable = true;
    # minecraft.enable = true;
    media.enable = true;
    attic.enable = true;
  };
}
