{
  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      extraFlags = [ "--quiet" ];
    };
    caskArgs = {
      appdir = "/Applications/homebrew";
    };
    brews = [
      # mas cli for searching for mac app store apps
      "mas"
    ];
    masApps = {
      Xcode = 497799835;
      Infuse = 1136220934;
      Tailscale = 1475387142;
      "Wifi Explorer" = 494803304;
      "Windows App" = 1295203466;
      "Microsoft Word" = 462054704;
    };
    casks = [
      # utilities
      "1password"
      "seafile-client"
      "scroll-reverser"
      # tools
      "stats"
      "balenaetcher"
      # development
      "visual-studio-code"
      "jetbrains-toolbox"
      "claude-code"
      "zed"
      # media
      "google-chrome"
      "spotify"
      "discord"
      "prismlauncher"
      "blender"
      # college
      "sf-symbols"
      "zoom"
      "unity-hub"
    ];
  };
}
