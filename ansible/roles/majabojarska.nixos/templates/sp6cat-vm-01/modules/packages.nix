{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    borgbackup
    btop
    busybox
    curl
    copyparty
    dig
    git
    htop
    inetutils
    iotop
    iperf
    lsof
    mtr
    ncdu
    nmap
    python3
    rsync
    sysstat
    tcpdump
    tmux
    vim
    wireguard-tools
    yazi
    zsh
  ];
}
