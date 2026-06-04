{ ... }:

{
  boot = {
    blacklistedKernelModules = [ "algif_aead" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    zfs = { forceImportRoot = false; };
  };
}
