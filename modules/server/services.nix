{ inputs, config, lib, pkgs, ... }: {
  imports = [ inputs.nix-helpers.nixosModules.py-backup ];

  # tailscale (and ssh)
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
    };
    # clean up lingering apps (gdu)
    logind.settings.Login.KillUserProcesses = true;
  };
  # networkd is needed for dns
  networking.useNetworkd = true;
  # filter out excessive logging
  systemd.services.tailscaled.serviceConfig.LogLevelMax = "notice";

  # backup
  services = {
    py-backup = {
      enable = true;
      interval = "*-*-* 4:00:00";
      settings = {
        services = map (s: "${s}.service") (builtins.attrNames
          (lib.attrsets.filterAttrs (_: v: v.autoStart)
            config.virtualisation.quadlet.containers));
        zpool = "zroot";
        datasets = [ "nixos" "srv" ];
      };
      restic = {
        repository = "s3:${config.private.restic.host}/${config.networking.hostName}-restic";
        retention = {
          days = 7;
          weeks = 4;
        };
      };
    };

    # sanoid is managed by py-backup, so its timer is masked
    sanoid = {
      enable = true;
      templates.default = {
        hourly = 0;
        daily = 7;
        weekly = 4;
        monthly = 0;
        autosnap = true;
        autoprune = true;
      };
      datasets.zroot = {
        useTemplate = [ "default" ];
        recursive = true;
        processChildrenOnly = true;
      };
    };
  };
  # these packages are needed by syncoid
  environment.systemPackages = with pkgs; [ mbuffer zstd ];

  # misc
  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}
