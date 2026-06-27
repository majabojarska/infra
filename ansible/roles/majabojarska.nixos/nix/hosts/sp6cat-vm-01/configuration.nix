{ lib, ... }:

{
  options = {
    sp6catVm01 = {
      ports = {
        anubis = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Anubis service port";
        };

        blog = lib.mkOption {
          type = lib.types.port;
          default = 8004;
          description = "Blog nginx service port";
        };

        fibo = lib.mkOption {
          type = lib.types.port;
          default = 8006;
          description = "Fibo service port";
        };

        nitter = lib.mkOption {
          type = lib.types.port;
          default = 8007;
          description = "Nitter service port";
        };
      };

      storage = {
        wdUsbHddCryptName = lib.mkOption {
          type = lib.types.str;
          default = "crypt-wd-usb-hdd";
          description = "WD USB HDD crypt device name";
        };

        wdUsbHddMountPath = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/wd-usb-hdd";
          description = "WD USB HDD mount path";
        };
      };
    };
  };

  imports = [
    ../../modules/i18n.nix
    ../../modules/globals.nix

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
