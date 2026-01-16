{ inputs, lib, config, ... }:
with inputs.nix-helpers.lib;
let
  cfg = config.apps.attic;
  id = toString cfg.user.id;
in
{
  imports = [ ./config.nix ./support.nix ];
  config = lib.mkIf cfg.enable {
    users = mkContainerUser { inherit (cfg.user) name id; };

    systemd.tmpfiles.rules = [
      "d /srv/attic/storage - ${id} ${id}"
      "d /srv/attic/postgres - ${id} ${id}"
    ];

    virtualisation.quadlet = {
      containers.attic = {
        containerConfig = {
          image = "ghcr.io/zhaofengli/attic:latest";
          autoUpdate = "registry";
          user = "${id}:${id}";
          exec = "-f /attic/server.toml";
          volumes = [
            "${config.sops.templates."attic/server.toml".path}:/attic/server.toml:ro"
            "/srv/attic/storage:/attic/storage"
          ];
          networks = [ "attic.network" "exposed.network" ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.services.attic.loadbalancer.server.port" = "8080";
          };
          healthCmd = "wget -O /dev/null -q -T 5 http://127.0.0.1:8080";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = mkContainerDeps [ "attic-postgres" ];
      };
      networks = { attic = { }; };
    };
  };
}
