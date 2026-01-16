{ lib, config, ... }:
let
  cfg = config.apps.attic;
  id = toString cfg.user.id;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.quadlet.containers = {
      attic-postgres.containerConfig = {
        image = "docker.io/library/postgres:17.6-alpine";
        autoUpdate = "registry";
        user = "${id}:${id}";
        environments = {
          POSTGRES_DB = "attic";
          POSTGRES_USER = "attic";
          POSTGRES_PASSWORD_FILE = "/run/secrets/attic__postgres__password";
        };
        secrets = [ "attic__postgres__password,uid=${id},gid=${id},mode=0400" ];
        volumes = [ "/srv/attic/postgres:/var/lib/postgresql/data" ];
        networks = [ "attic.network" ];
        healthCmd = "pg_isready -d attic -U attic";
        healthStartupCmd = "sleep 10";
        healthOnFailure = "kill";
      };
    };
  };
}
