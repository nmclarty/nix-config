{ inputs, pkgs, lib, ... }: {
  # import flake module
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
  # sbctl to manage keys and for debugging
  environment.systemPackages = with pkgs; [ sbctl ];
  boot = {
    # lanzaboote replaces systemd-boot
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # automatic provisioning
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };
  };
}
