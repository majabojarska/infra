{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, agenix, nixpkgs, copyparty, }: {
    nixosConfigurations = {
      
      kube-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/kube-01/hardware-configuration.nix
          ./hosts/kube-01/configuration.nix
          agenix.nixosModules.default
        ];
      };
      
      sp6cat-vm-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/sp6cat-vm-01/hardware-configuration.nix
          ./hosts/sp6cat-vm-01/configuration.nix
          agenix.nixosModules.default
          copyparty.nixosModules.default
          (
            { pkgs, ... }:
            {
              # add the copyparty overlay to expose the package to the module
              nixpkgs.overlays = [ copyparty.overlays.default ];
            }
          )
        ];
      };

      nas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nas/hardware-configuration.nix
          ./hosts/nas/configuration.nix
        ];
      };
    
    };
  };
}
