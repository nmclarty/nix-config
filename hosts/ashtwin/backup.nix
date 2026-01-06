{ lib, inputs, config, pkgs, ... }:
let
  enabledHosts = builtins.attrNames
    (lib.attrsets.filterAttrs (n: v: n != config.networking.hostName && v.config.services.sanoid.enable)
      inputs.self.nixosConfigurations);
in
{
  systemd = {
    services.syncoid = {
      after = [ "network-online.target" "zfs.target" ];
      requires = [ "network-online.target" "zfs.target" ];
      path = with pkgs; [
        sanoid
        moreutils
      ];
      environment.HOME = "/root"; # mbuffer needs this
      script = ''
        set -euo pipefail

        parallel -i syncoid --recursive \
            --compress=zstd-fast \
            --exclude-snaps=backup \
            --sshoption=UserKnownHostsFile=${config.sops.secrets."known_hosts".path} \
            "root@{}:zroot" "cold/backup/{}" -- ${lib.concatStringsSep " " enabledHosts}
      '';
    };
    timers.syncoid = {
      enable = true;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 5:00:00";
        Persistent = true;
      };
    };
  };
}
