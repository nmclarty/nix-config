{ pkgs, ... }: {
  # extra packages
  home.packages = with pkgs; [
    # languages
    python3
    nodejs
    go
    rustc
    gcc
    # managers
    cargo
    # tools
    gh
    shellcheck
    # nix
    nixd
    statix
    deadnix
    nixpkgs-fmt
  ];
}
