{ inputs, lib, config, ... }:
with inputs.nix-helpers.lib;
let
  cfg = config.apps.attic;
in
{
  config = lib.mkIf cfg.enable {
    sops = {
      secrets = mkSecrets [
        "attic/token"
        "attic/postgres/password"
      ] "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";

      templates."attic/server.toml" = {
        restartUnits = [ "attic.service" ];
        owner = cfg.user.name;
        content =
          let
            token = config.sops.placeholder."attic/token";
            pg_pw = config.sops.placeholder."attic/postgres/password";
          in
          ''
            listen = "[::]:8080"
            allowed-hosts = []

            [database]
            url = "postgres://attic:${pg_pw}@attic-postgres:5432/attic"

            [storage]
            type = "local"
            path = "/attic/storage"

            [chunking]
            nar-size-threshold = 65536
            min-size = 16384
            avg-size = 65536
            max-size = 262144

            [compression]
            type = "zstd"

            [garbage-collection]
            interval = "12 hours"

            [jwt.signing]
            token-hs256-secret-base64 = "${token}"
          '';
      };
    };
  };
}
