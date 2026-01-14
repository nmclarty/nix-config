{ config, lib, inputs, ... }:
with lib;
{
  config = mkIf config.server.ups.enable {
    sops.secrets."nut/monuser".sopsFile = "${inputs.nix-private}/secrets.yaml";
    power.ups = {
      enable = true;
      mode = "netclient";
      users.monuser = {
        passwordFile = config.sops.secrets."nut/monuser".path;
        upsmon = "secondary";
      };
      upsmon.monitor.primary = {
        passwordFile = config.sops.secrets."nut/monuser".path;
        system = "primary@timberhearth";
        type = "secondary";
        user = "monuser";
      };
    };
  };
}
