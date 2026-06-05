{ ... }:

{
  boot = {
    blacklistedKernelModules = [ "algif_aead" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "aesni_intel"
      "cryptd"
    ];
    zfs.forceImportRoot = false;
  };
}
