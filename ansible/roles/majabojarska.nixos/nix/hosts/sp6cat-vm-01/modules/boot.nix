{ ... }:

{
  boot = {
    blacklistedKernelModules = [ "algif_aead" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd = {
      network = {
        ssh = {

        }
      }
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];
    };
    zfs.forceImportRoot = false;
  };
}
