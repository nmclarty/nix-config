{ lib, ... }:
with lib;
{
  imports = [
    ./services.nix
    ./podman.nix
    ./ups.nix
    ./system.nix
  ];
  options.server = {
    ups.enable = mkOption {
      type = types.bool;
      default = true;
      description = "If ups monitoring should be enabled.";
    };
  };
}
