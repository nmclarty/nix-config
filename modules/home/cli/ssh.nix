{ inputs, ... }:
let
  # automatically enable agent forwarding for rssh on servers
  server = builtins.mapAttrs (_: _: { forwardAgent = true; }) inputs.self.nixosConfigurations;
  manual = {
    "github.com" = {
      # ssh (port 22) is sometimes blocked by firewalls, so use port 443
      hostname = "ssh.github.com";
      port = 443;
    };
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = server // manual;
  };
}
