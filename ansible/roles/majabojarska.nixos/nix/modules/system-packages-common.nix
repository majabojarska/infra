{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    curl
    cryptsetup
    dig
    dmidecode
    file
    git
    htop
    iftop
    inetutils
    iotop
    iperf
    lsof
    mtr
    ncdu
    net-tools
    nmap
    parallel
    parted
    pciutils
    python3
    rsync
    stress
    sysstat
    tcpdump
    tmux
    tree
    unzip
    vim
    wget
    zerofree
    zsh
  ];
}
