{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, agenix, nixpkgs, }: {
    nixosConfigurations.kube-01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        agenix.nixosModules.default
      ];
    };
  };
}
