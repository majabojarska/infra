# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config
, pkgs
, lib
, ...
}:

{
  imports = [ ./secrets.nix ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
    persistent = true;
  };

  services.fstrim.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = {
        configurationLimit = 20;
      };
    };
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [
      "storage"
      "media"
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  hardware = {
    # enableAllFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-ocl # Generic OpenCL support
        intel-media-driver # Broadwell (5th gen) and newer, user with LIBVA_DRIVER_NAME=iHD
      ];
    };
    rtl-sdr.enable = true;
  };

  systemd.network.wait-online.enable = false;

  networking = {
    hostName = "kube-01";
    domain = "home.majabojarska.dev";
    hostId = "132aea15"; # First 8 chars from /etc/machine-id

    networkmanager.enable = true;
    interfaces.ens18.useDHCP = true;

    firewall = {
      trustedInterfaces = [
        "ens18"
        "tailscale0"
      ];

      allowedTCPPorts = [
        6443 # kube api server
        80 # HTTP
        443 # HTTPS
      ];

      allowedUDPPorts = [ config.services.tailscale.port ];

      extraCommands = ''
        # kubelet metrics
        iptables -I INPUT -p tcp -s 10.42.0.0/16 --dport 10250 -j ACCEPT
      '';
    };
  };

  powerManagement = {
    powertop.enable = true;
    cpuFreqGovernor = "conservative";
  };

  users.groups = {
    kubernetes = {
      gid = 10001;
    };
    media = {
      gid = 10002;
    };
    immich = {
      gid = 10003;
    };
    openwebrx = {
      gid = 10004;
    };
    jellyfin = {
      gid = 10005;
    };
    arr = {
      gid = 10006;
    };
    zigbee = {
      gid = 10007;
    };
  };

  # Human-like users
  users.users = {
    maja = {
      isNormalUser = true;
      description = "maja";
      extraGroups = [
        "networkmanager"
        "wheel"
        "media"
        "kubernetes"
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBch2rzzVEnWcUbHJctteozpAFyJYXnd8wMC7DWXS9rL" # FP5

        # Akamai MBP
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNGBqGuCLlq5zZdOpjqK9z3g0uoWWmZEZdpLaF6I+V5orOjjBHDo5xJOLoR95PQlW2K4HG9TfOL7MzdndqMQwSUUycix1xWzytoy2XSpmWcXEHztsPBADcEdalfTcaPAIggPtUhGzQTkk4s31ripixtnfTs675ylPuRhiOWC+NNSYFDoAQNiwHL5+HIvdjL2jNGgYUQPUUL90fZcyBj6zOuSgTCU+zRxZtW+7aMhio0FeW8Rs/W4uVfQrDrFPU3d+Rnj9lU35/9UGUEY78rsPFPYxr5cqcDhCyyO0a8MX1so7nzxJB//RJOcBnUd5pUACxISHQ0Q8VYzT1nzPMsG6kOpGKml5KCdgenxMTVpc3is3/9A96C+Rnx4z1WuCTNj+85rJ1hfu40NnWzmytShl9lVQ1WqKcYVEcg8zIjIkKRBa/CFz2UzLtxQHSRoaoC0tk3UeaKBnrmuzyOL3vLEcYAh4C1kNze83uupTiRHK9xWFOZHY8c5loCzzGo2V+3nC20sS5JfFbaQbwdn4fcZzQNcK7wHo/vfDTH5JpbBLeEVFHxaTKG0MjRQgB3DdA/MaXDxNr4hxrzP+FSuhRfT4wnQA87CHJ5zF5RRn/jtUEfrBC80Y5ACOsWlNhpB8yMRY1goW/TmlCL3HOLlj1zl6uXTvaFJ9hinDKxpXX4bHjYQ=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvfO8n2MZAT4bhdfV1AevvImyD1BcYPoim2EKirKiTVA5HuBm8tEFn2kKcB9FSq5nJVKC7tPtIQNO/fE7z0HSIPAxys1fRc1Z64dOb31KCSki4dkvPE8288+0tEaeOiCQM8JjMH5JrhZ1qwFovLBYXeA34isT14r04hl//xlJe4ujXp2P7TvUxf8HFUVzxVU9msa4gxhNrO/bsJTPWyuzfNoEY/WBI1FKqHn1COQK6+eC4MGZytZHnR+nFu/8X/vbNphwLQrfVQnmmc5IHF/C/Z9vWbrSa3hPA6VjzHxr+V5/b890gKajywMnpiTxOPuZcCnCC3h9iLTzaL4Q5ac2Uo5u/TY3XeeK8RexsCtouIz6mcL3u2AVtskZaMnwYKr284fsMnI7GCujOX9QzLW7206wzShn2/kEweMMHSOF8tInndWC9ElniYspNwFR6tWNlWq1FciU4PuKKl9bUSycJ3yhYb8QyvriL/RU5z1X+hv91o4kRUacnG98gXz3PaP4xE9wplkSTZ/2LrC7qiX5dYu+XVsNyNRbrZoa7rxbBIRdr+bH3wVGkmwvAlu/fCYqGM1NXvNJmR/dAr30hH1KhGqPDibWWK7I0eRh5cipC2zgCtb4cfMCIJF2W/34yWCptqyKx6J58TCbSPf3WRuCLbFydkV65Yb5MQtRprRLjHw=="
      ];
    };
  };

  # Service users
  users.users = {
    kubernetes = {
      isSystemUser = true;
      group = "kubernetes";
      uid = 10001;
      description = "Generic Kubernetes";
    };
    immich = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "immich";
      uid = 10003;
      description = "Immich";
      extraGroups = [
        "kubernetes"
        "video" # /dev/dri/cardX
        "render" # /dri/renderX
      ];
    };
    jellyfin = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "jellyfin";
      uid = 10005;
      description = "Jellyfin";
      extraGroups = [
        "kubernetes"
        "media"
        "video" # /dev/dri/cardX
        "render" # /dri/renderX
      ];
    };
    openwebrx = {
      isSystemUser = true;
      # isNormalUser = false;
      uid = 10004;
      group = "openwebrx";
      extraGroups = [ "plugdev" ];
    };
    arr = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "arr";
      uid = 10006;
      description = "Arr stack";
      extraGroups = [
        "kubernetes"
        "media"
      ];
    };
    zigbee = {
      isSystemUser = true;
      group = "zigbee";
      uid = 10007;
      description = "ZigBee";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "maja" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

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

  services.qemuGuest.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "storage/kubernetes" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        # yearly = 12;
        autosnap = true;
        autoprune = true;
      };
      "storage/media" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 1 * * * root shutdown now"
    ];
  };

  services.prometheus.exporters.zfs.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3; # Ban IP after N failures
    ignoreIP = [
      # Whitelist private IP ranges
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    jails = { };
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--data-dir /var/lib/rancher/k3s"
      # Needed for etcd to init properly, or convert from sqlite if k3s server was first started without this flag.
      # https://docs.k3s.io/datastore/ha-embedded?_highlight=cluster&_highlight=init#existing-single-node-clusters
      "--cluster-init"

      "--tls-san ${config.networking.hostName}.${config.networking.domain}" # https://docs.k3s.io/cli/server#k3s-server-cli-help

      # "--debug"
      # "-v=3"
      "--enable-pprof"
      # Disable built-in extension features
      # https://docs.k3s.io/installation/packaged-components?_highlight=disable#disabling-manifests
      "--disable=traefik"
      "--disable=local-storage"
      "--disable=metrics-server"
      "--disable-network-policy"
      # This is not equivalent to the metrics-server, it's just etcd metrics
      "--etcd-expose-metrics=true"

      # ETCD snapshotting
      # https://docs.k3s.io/cli/server#commonly-used-options
      ''--etcd-snapshot-schedule-cron="0 */8 * * *"''
      "--etcd-snapshot-retention=64"
      "--etcd-snapshot-compress"
      "--etcd-snapshot-dir=/storage/kubernetes/snapshots"

      # Cleanup old images more aggressively
      # https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
      "--kubelet-arg='--image-gc-low-threshold=20'"
      "--kubelet-arg='--image-gc-high-threshold=50'"

      # To handle the shitbox performance of the conservative CPU governor, for powersaving purposes.
      # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
      "--kube-controller-manager-arg='--leader-elect-lease-duration=60s'"
      "--kube-controller-manager-arg='--leader-elect-renew-deadline=40s'"
      "--kube-controller-manager-arg='--leader-elect-retry-period=5s'"
    ];
  };

  systemd.services."k3s-graceful-stop@${config.networking.hostName}" = {
    enable = true;
    description = "Ensures graceful workload stop upon k3s stop";

    wantedBy = [ "k3s.service" ];

    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    unitConfig = {
      After = [ "k3s.service" ];
      BindsTo = [ "k3s.service" ];
    };

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.k3s}/bin/kubectl uncordon %i";
      ExecStart = "${pkgs.coreutils}/bin/sleep inf";
      ExecStop = "${pkgs.k3s}/bin/kubectl drain %i --ignore-daemonsets --delete-emptydir-data --disable-eviction";
    };
  };

  services.borgmatic = {
    enable = true;
    enableConfigCheck = true;
    configurations."kubernetes" = {
      # zfs = { }; # Enables ZFS in borgmatic # TODO:
      source_directories = [
        # K3s state
        # "/var/lib/rancher/k3s/server/db/snapshots"
        # "/var/lib/rancher/k3s/server/token"
        # Persistent Volumes
        "/storage/kubernetes/"
      ];
      exclude_patterns = [
        "*/.zfs" # Contains ZFS snapdir, backing this up would be redundant.
      ];
      repositories = [
        {
          label = "kubernetes-offsite-vps-01";
          path = "ssh://borg@vps-01.cloud.majabojarska.dev/mnt/backup/kube-01/kubernetes";
        }
      ];
      exclude_if_present = [ ".nobackup" ];
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${
        config.age.secrets."borgmatic-kubernetes-enc-pass".path
      }";
      relocated_repo_access_is_ok = true;
      compression = "auto,zstd,10";
      before_backup = [
        # Couple volume backup with ETCD state
        "${pkgs.k3s}/bin/k3s etcd-snapshot save --name borgmatic --etcd-snapshot-compress --etcd-snapshot-dir=/storage/kubernetes/snapshots"
        # Drain node and stop K3s
        "systemctl stop k3s.service"
        # Killall k3s https://docs.k3s.io/upgrades/killall#killall-script
        "${pkgs.k3s}/bin/k3s-killall.sh"
      ];
      after_actions = [
        # Restart k3s
        "systemctl restart k3s.service"
      ];

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 3;
      keep_yearly = 0;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
