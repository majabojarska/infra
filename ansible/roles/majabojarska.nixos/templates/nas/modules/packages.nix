{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    btop
    borgbackup
    curl
    htop
    iftop
    iotop
    iperf
    ncdu
    parted
    python3
    tmux
    tree
    vim
    wget
    yazi
    zfs
    zsh
  ];
}
