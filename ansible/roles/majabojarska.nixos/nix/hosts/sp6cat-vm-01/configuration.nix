{ ... }:

{
  _module.args = {
    wdUsbHddCryptName = "crypt-wd-usb-hdd";
    wdUsbHddMountPath = "/mnt/wd-usb-hdd";
  };

  imports = [
    ../../modules/i18n.nix

    ./secrets.nix
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/storage.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
