{ config, inputs, lib, ... }:
with lib;
{
  sops.secrets."nut/admin".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  # for some reason, nut seems to spam this (seemingly) benign error
  systemd.services.upsdrv.serviceConfig.LogFilterPatterns = "~nut_libusb_get_(report|string): Input/Output Error";
  power.ups = {
    mode = mkForce "netserver"; # override the default mode
    upsd.listen = [{ address = "0.0.0.0"; }];
    ups.primary = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Cyberpower UPS - All servers";
      directives = [ "pollfreq = 5" "productid = 0601" "pollonly" ];
    };
    # admin user for full access
    users.admin = {
      passwordFile = config.sops.secrets."nut/admin".path;
      actions = [ "SET" "FSD" ];
      instcmds = [ "ALL" ];
      upsmon = "primary";
    };
    # override the default monitor settings
    upsmon.monitor.primary = {
      passwordFile = mkForce config.sops.secrets."nut/admin".path;
      system = mkForce "primary@127.0.0.1";
      type = mkForce "primary";
      user = mkForce "admin";
    };
  };
}
