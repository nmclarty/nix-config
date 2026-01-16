{
  description = "A NixOS flake for managing my computers.";
  inputs = {
    # system
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # utilities
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    # personal
    nix-private.url = "github:nmclarty/nix-private?ref=dev";
    nix-private.inputs.nixpkgs.follows = "nixpkgs";
    nix-helpers.url = "github:nmclarty/nix-helpers";
    nix-helpers.inputs.nixpkgs.follows = "nixpkgs";
    # extras
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    quadlet-nix.url = "github:seiarotg/quadlet-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };
  # Load the blueprint
  outputs = inputs:
    inputs.blueprint { inherit inputs; };
}
