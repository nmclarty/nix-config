{ flake, pkgs, ... }:
{
  imports = with flake.modules.home; [
    default
    extra-devel
  ];

  systemd.user.services.wsl2-ssh-agent = {
    Unit = {
      Description = "WSL2 SSH Agent Bridge";
      After = [ "network.target" ];
      ConditionUser = "!root";
    };
    Service = {
      ExecStart = "${pkgs.wsl2-ssh-agent}/bin/wsl2-ssh-agent --verbose --foreground --socket=%t/wsl2-ssh-agent.sock";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
