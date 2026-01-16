{ config, flake, inputs, ... }:
with inputs.nix-helpers.lib;
{
  system = {
    stateVersion = "25.05";
    # the full git ref that the system was built from
    configurationRevision = flake.rev or flake.dirtyRev or "unknown";
  };

  # locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb.layout = "us";

  # enable nonfree firmware
  hardware.enableRedistributableFirmware = true;

  # use zram for memory compression
  zramSwap.enable = true;

  # nix settings
  sops = {
    secrets = mkSecrets [
      "github/token"
      "attic/public_key"
      "attic/access_token"
    ] "${inputs.nix-private}/secrets.yaml";
    templates = {
      "nix/github-config" = {
        owner = "nmclarty";
        content = ''
          extra-access-tokens = github.com=${config.sops.placeholder."github/token"}
        '';
      };
      "nix/attic-config" = {
        owner = "nmclarty";
        content = ''
          extra-substituters = https://attic.${config.private.domain}/nix-config
          extra-trusted-public-keys = ${config.sops.placeholder."attic/public_key"}
        '';
      };
      "nix/attic-netrc" = {
        owner = "nmclarty";
        content = ''
          machine attic.${config.private.domain}
          password ${config.sops.placeholder."attic/access_token"}
        '';
      };
    };
  };
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    extraOptions = ''
      netrc-file = ${config.sops.templates."nix/attic-netrc".path}
      !include ${config.sops.templates."nix/github-config".path}
      !include ${config.sops.templates."nix/attic-config".path}
    '';
  };
}
