{ config, inputs, ... }: {
  system.autoUpgrade = {
    enable = true;
    flake = "github:nmclarty/nix-config";
    # timer
    dates = "*-*-* 6:00:00";
    persistent = true;
    randomizedDelaySec = "30m";
    # reboot
    allowReboot = true;
    rebootWindow = {
      lower = "05:00";
      upper = "06:00";
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.overcommit_memory" = 1; # allow overcommit for redis
  };

  sops.secrets."nmclarty/ssh/authorized_keys".sopsFile = "${inputs.nix-private}/secrets.yaml";
  security.pam = {
    rssh = {
      enable = true;
      settings = {
        cue = true;
        cue_prompt = "Authenticating with ssh-agent...";
        auth_key_file = config.sops.secrets."nmclarty/ssh/authorized_keys".path;
      };
    };
    services.sudo.rssh = true;
  };

  # use systemd boot (instead of grub)
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      configurationLimit = 5;
      enable = true;
    };
  };
}
