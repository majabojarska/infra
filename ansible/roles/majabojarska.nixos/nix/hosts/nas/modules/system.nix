{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:

let
  proxmoxBridge = "vmbr0";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/proxmox-image.nix")
  ];

  boot = {
    kernelParams = [ "console=ttyS0" ];
    zfs.forceImportRoot = false;
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

  virtualisation.diskSize = 32 * 1024; # 32 GB

  proxmox = {
    qemuConf = {
      bios = "ovmf";
      cores = 4;
      memory = 8192;
      agent = true;
      net0 = "virtio,bridge=${proxmoxBridge},firewall=1";
    };
    cloudInit.enable = false;
  };

}
