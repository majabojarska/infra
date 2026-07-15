{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = { configurationLimit = 20; };
    };
    blacklistedKernelModules = [ "algif_aead" ];
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "storage" "media" ];
    };
  };
}
