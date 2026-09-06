{ config, ... }:

{
  imports = [
    ../../modules/i18n.nix
    ../../modules/globals.nix
    ../../modules/logrotate.nix
    ../../modules/shell-bash-fzf.nix
    ../../modules/docker.nix
    {
      dataRoot = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/docker";
    }

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
