{ pkgs, ... }:

{
  imports = [ ../../../modules/system-packages-common.nix ];

  environment.systemPackages = with pkgs; [
    busybox
    copyparty
    nodejs-slim
    wireguard-tools
    smartmontools
    sqlite-utils
    zfs
  ];
}
