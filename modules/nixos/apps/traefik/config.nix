{ inputs, lib, config, ... }:
with inputs.nix-helpers.lib;
let
  cfg = config.apps.traefik;
in
{
  config = lib.mkIf cfg.enable {
    sops = {
      secrets = mkSecrets [
        "traefik/dns_token"
      ] "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";

      templates = {
        "traefik/traefik.yaml" = {
          restartUnits = [ "traefik.service" ];
          owner = cfg.user.name;
          content = ''
            global:
              sendAnonymousUsage: true
            log:
              level: INFO
            ping:
              entryPoint: http
            accessLog:
              filePath: /data/logs/access.log

            entryPoints:
              http:
                address: :80
                http:
                  redirections:
                    entryPoint:
                      to: https
                      scheme: https
              https:
                address: :443
                asDefault: true
                http:
                  middlewares:
                    - security@file
                  tls:
                    certResolver: cloudflare
                    domains:
                      - main: "${config.apps.domain}"
                        sans:
                          - "*.${config.apps.domain}"
                # fix for immich timeouts
                transport:
                  respondingTimeouts:
                    readTimeout: "0s"

            providers:
              file:
                filename: /etc/traefik/dynamic.yaml
              docker:
                endpoint: "tcp://socket-proxy:2375"
                exposedByDefault: false
                network: "exposed"
                allowEmptyServices: true
                defaultRule: "Host(`{{ normalize .ContainerName }}.${config.apps.domain}`)"

            api:
              dashboard: true
              disabledashboardad: true

            certificatesResolvers:
              cloudflare:
                acme:
                  storage: /data/acme.json
                  dnsChallenge:
                    provider: cloudflare
          '';
        };
        "traefik/dynamic.yaml" = {
          restartUnits = [ "traefik.service" ];
          owner = cfg.user.name;
          content = ''
            http:
              middlewares:
                security:
                  headers:
                    contentTypeNosniff: true
                    frameDeny: true
                    stsSeconds: 63072000
                    stsIncludeSubdomains: true
                    referrerPolicy: "strict-origin-when-cross-origin"
                    customResponseHeaders:
                      server: ""
                      x-powered-by: ""
          '';
        };

        "ddclient/ddclient.conf" = {
          restartUnits = [ "ddclient.service" ];
          owner = cfg.user.name;
          content = ''
            # general
            daemon=300
            # syslog=yes
            # ssl=yes

            # router
            usev4=webv4
            usev6=webv6

            # protocol
            protocol=cloudflare, \
            zone=${config.apps.domain}, \
            login=token, \
            password=${config.sops.placeholder."traefik/dns_token"} \
            *.${config.apps.domain}
          '';
        };
      };
    };
  };
}
