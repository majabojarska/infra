{ config, ... }:

let
  _wd_usb_hdd_name = "crypt-wd-usb-hdd";
in

{

  environment.etc.crypttab = {
    mode = "0600";
    text = ''
      # <volume-name> <encrypted-device> [key-file] [options]
      ${_wd_usb_hdd_name} /dev/disk/by-label/CRYPT_WD_USB_HDD ${
        config.age.secrets."wd-usb-hdd-key".path
      } luks
    '';
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/CB58-531A";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/" = {
      device = "/dev/mapper/luks-af1757e6-0789-4cd6-99aa-311e7b6ae5cf";
      fsType = "ext4";
    };

    "/mnt/wd-usd-hdd" = {
      device = "/dev/mapper/${_wd_usb_hdd_name}";
      fsType = "ext4";
      options = [
        "noatime" # prevent atime updates on the filesystem
        "users" # allows any user to mount and unmount
        "nofail" # prevent system from failing if this drive doesn't mount
      ];
    };
  };

}
