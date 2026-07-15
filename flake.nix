{
  description = "Development environment for infra repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      devenv,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devenv.flakeModule ];
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devenv.shells.default = {
            devenv.root = builtins.toString ./.;

            packages = with pkgs; [
              deploy-rs
              nixd
              nil
              nixfmt
              statix
              deadnix
              nix-output-monitor
              age
              ssh-to-age
              sops
              jq
              yq
              openssh
              git
            ];

            enterShell = ''
              export NIX_CONFIG="experimental-features = nix-command flakes"
            '';

            scripts = {
              flake-check.exec = "nix flake check ./ansible/roles/majabojarska.nixos/nix";
              flake-update.exec = "nix flake update --flake ./ansible/roles/majabojarska.nixos/nix";
              deploy-build.exec = "deploy --flake ./ansible/roles/majabojarska.nixos/nix --dry-activate";
              deploy-apply.exec = "deploy --flake ./ansible/roles/majabojarska.nixos/nix";
            };
          };

        };
    };
}
