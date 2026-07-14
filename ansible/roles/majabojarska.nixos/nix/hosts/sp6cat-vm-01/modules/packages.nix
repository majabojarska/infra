{ pkgs, ... }:

{
  imports = [ ../../../modules/system-packages-common.nix ];

  environment.systemPackages = with pkgs; [
    busybox
    copyparty

    wireguard-tools
    # Telegram
    tdl
    telegram-desktop

    smartmontools
    sqlite-utils
    zfs
  ];
}
