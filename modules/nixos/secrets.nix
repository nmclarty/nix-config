{ config, inputs, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
    log = [ "secretChanges" ];
    age = {
      generateKey = true;
      sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
      keyFile = "/var/lib/sops-nix/key.txt";
    };
    secrets = {
      "known_hosts" = {
        sopsFile = "${inputs.nix-private}/secrets.yaml";
        mode = "0444"; # safe since it only contains public keys
      };
    };
  };
}
