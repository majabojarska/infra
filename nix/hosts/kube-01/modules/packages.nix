{ pkgs, ... }:

{
  imports = [ ../../../modules/system-packages-common.nix ];

  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    borgbackup
    borgmatic
    cilium-cli
    drm_info
    ffmpeg-full
    fio
    immich-cli
    intel-gpu-tools
    k3s
    kubernetes-helm
    lazydocker
    libva-utils
    mediainfo
    parallel
    smartmontools
    zfs
  ];
}
