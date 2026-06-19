{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    copyparty.url = "github:9001/copyparty";
  };
  outputs =
    {
      self,
      agenix,
      nixpkgs,
      copyparty,
    }:
    {
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

        nas-old = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nas-old/hardware-configuration.nix
            ./hosts/nas-old/configuration.nix
          ];
        };

        nas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nas/configuration.nix
          ];
        };
      };

      packages.x86_64-linux = {
        nas-vma = self.nixosConfigurations.nas.config.system.build.VMA;
        # Keep `default` aligned with the Proxmox import artifact.
        default = self.nixosConfigurations.nas.config.system.build.VMA;
      };
    };
}
