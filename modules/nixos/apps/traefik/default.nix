{ inputs, lib, config, ... }:
with inputs.nix-helpers.lib;
let
  cfg = config.apps.traefik;
  id = toString cfg.user.id;
in
{
  imports = [ ./config.nix ];
  config = lib.mkIf cfg.enable {
    # user
    users = mkContainerUser { inherit (cfg.user) name id; };

    # dirs
    systemd.tmpfiles.rules = [
      "d /srv/traefik - ${id} ${id}"
    ];

    # containers
    virtualisation.quadlet = {
      containers = {
        traefik = {
          containerConfig = {
            image = "docker.io/library/traefik:${cfg.tag}";
            autoUpdate = "registry";
            user = "${id}:${id}";
            environments = {
              CF_DNS_API_TOKEN_FILE = "/run/secrets/traefik__dns_token";
            };
            secrets = [ "traefik__dns_token,uid=${id},gid=${id},mode=0400" ];
            volumes = [
              "${config.sops.templates."traefik/traefik.yaml".path}:/etc/traefik/traefik.yaml:ro"
              "${config.sops.templates."traefik/dynamic.yaml".path}:/etc/traefik/dynamic.yaml:ro"
              "/srv/traefik:/data"
            ];
            sysctl."net.ipv4.ip_unprivileged_port_start" = "80";
            publishPorts = [
              "80:80" # main http
              "443:443" # main https
            ];
            networks = [ "socket-proxy" "exposed:ip=10.90.0.2" ];
            labels = {
              "traefik.enable" = "true";
              "traefik.http.routers.traefik.service" = "api@internal";
              "traefik.http.routers.traefik.middlewares" = "tinyauth";
            };
            healthCmd = "traefik healthcheck";
            healthStartupCmd = "sleep 10";
            healthOnFailure = "kill";
          };
          unitConfig = mkContainerDeps [ "socket-proxy" ];
        };

        socket-proxy = {
          containerConfig = {
            image = "lscr.io/linuxserver/socket-proxy:latest";
            autoUpdate = "registry";
            readOnly = true;
            tmpfses = [ "/tmp" ];
            environments = {
              CONTAINERS = "1";
              LOG_LEVEL = "notice";
            };
            volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];
            networks = [ "socket-proxy.network" ];
            healthCmd = "wget -O - -q -T 5 http://127.0.0.1:2375/_ping";
            healthStartupCmd = "sleep 10";
            healthOnFailure = "kill";
          };
        };

        ddclient = {
          containerConfig = {
            image = "lscr.io/linuxserver/ddclient:latest";
            autoUpdate = "registry";
            user = "${id}:${id}";
            volumes = [ "${config.sops.templates."ddclient/ddclient.conf".path}:/config/ddclient.conf" ];
          };
        };
      };
      networks = {
        socket-proxy.networkConfig.internal = true;
        exposed.networkConfig = {
          subnets = [ "10.90.0.0/24" ];
          ipRanges = [ "10.90.0.5-10.90.0.254" ];
        };
      };
    };
  };
}
