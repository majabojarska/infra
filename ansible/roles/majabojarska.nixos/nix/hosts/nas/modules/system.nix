{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [ "console=ttyS0" ];
    loader.grub.device = lib.mkDefault "/dev/vda";
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
      persistent = true;
    };
  };

  services.qemuGuest.enable = true;

  system.build.qcow2 = import "${modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 10240;
    format = "qcow2";
    partitionTableType = "hybrid";
  };
}
