{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    borgmatic
    borgbackup
    btop
    busybox
    cilium-cli
    curl
    delta
    dig
    dmidecode
    drm_info
    ffmpeg-full
    file
    fio
    htop
    iftop
    immich-cli
    intel-gpu-tools
    iotop
    iperf
    jq
    k3s
    k9s
    kubernetes-helm
    libva-utils
    lsof
    mediainfo
    ncdu
    nmap
    parallel
    parted
    pciutils
    powertop
    python3
    rclone
    ripgrep
    rsync
    smartmontools
    stress
    tmux
    tree
    unzip
    vim
    wget
    yazi
    yq
    zerofree
    zfs
    zsh
  ];
}
