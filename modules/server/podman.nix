{ config, inputs, ... }: {
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    nix-private.nixosModules.private
    nix-helpers.nixosModules.sops-podman
  ];
  private.enable = true;

  services.sops-podman = {
    enable = true;
    settings.sopsFile = "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";
  };

  systemd.services.podman.environment.LOGGING = "--log-level=warn"; # reduce log spam
  virtualisation = {
    containers = {
      enable = true;
      containersConf.settings = {
        containers.tz = "local";
        engine.events_logger = "file";
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };
    quadlet = {
      enable = true;
      autoUpdate = {
        enable = true;
        calendar = "weekly";
      };
    };
  };
  # for rootful userns
  users.users.containers = {
    isSystemUser = true;
    autoSubUidGidRange = true;
    group = "containers";
  };
  users.groups.containers = { };
}
