{ config, ... }:
let
  privateShare = p: {
    "path" = p;
    "writable" = "yes";
    # access
    "valid users" = "nmclarty";
    "public" = "no";
    # filesystem
    "create mask" = "0644";
    "force user" = "nmclarty";
    "force group" = "users";
  };
in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = config.networking.hostName;
        "netbios name" = config.networking.hostName;
        "security" = "user";
      };

      # shares
      home = privateShare "/cold/shares/home";
      games = privateShare "/cold/shares/games";
    };
  };
}
