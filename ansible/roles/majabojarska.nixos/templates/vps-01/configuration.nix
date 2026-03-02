# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config
, lib
, pkgs
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

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_Backups";
    fsType = "ext4";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "defaults"
      "noatime"
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    noCheck = true;
    autoResize = true;
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_Storage";
    fsType = "ext4";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "defaults"
      "noatime"
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    noCheck = true;
    autoResize = true;
  };

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

  # Human-like users
  users = {
    groups = {
      www-data = {
        members = [
          "nginx"
          "maja"
        ];
      };
    };
    users = {
      maja = {
        isNormalUser = true;
        description = "maja";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        packages = with pkgs; [ ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBch2rzzVEnWcUbHJctteozpAFyJYXnd8wMC7DWXS9rL" # FP5
        ];
      };
      www-data = {
        isNormalUser = true;
        description = "Deploys WWW data";
        group = "www-data";
        home = "/var/www";
        homeMode = "750";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZU7nJ9AUBywX6+icIJ3t4NCEoIbnEOzEfGxYYSX5dI" # Bitwarden: SSH key vps-01 deploy-blog
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
        ];
      };
    };
  };

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
    tmux
    vim
    wireguard-tools
    yazi
    zsh
  ];

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
      value = "20000";
    }
  ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    disableTaildrop = true;
    authKeyFile = config.age.secrets."tailscale-auth-key".path;
    extraUpFlags = [
      "--accept-routes"
      "--advertise-exit-node"
    ];
  };

  # Enable the OpenSSH daemon.
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

  environment.etc = {
    # Define an action that will trigger a Ntfy push notification upon the issue of every new ban
    # TODO
    # "fail2ban/action.d/ntfy.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
    #   [Definition]
    #   norestored = true # Needed to avoid receiving a new notification after every restart
    #   actionban = curl -H "Title: <ip> has been banned" -d "<name> jail has banned <ip> from accessing $(hostname) after <failures> attempts of hacking the system." https://ntfy.sh/Fail2banNotifications
    # '');
    # Defines a filter that detects URL probing by reading the Nginx access log
    # "fail2ban/filter.d/nextcloud.local".text = pkgs.lib.mkDefault (
    #   pkgs.lib.mkAfter ''
    #     [Definition]
    #     _groupsre = (?:(?:,?\\s*\"\\w+\":(?:\"[^\"]+\"|\\w+))*)
    #     failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
    #                 ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
    #     datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
    #   ''
    # );
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

  networking = {
    hostName = "vps-01";
    domain = "cloud.majabojarska.dev";
    hostId = "5c2a6d27"; # First 8 chars from /etc/machine-id

    firewall = {
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [
        20001 # wg-baczek wireguard
        123 # NTP
        443 # HTTP3
      ];
      checkReversePath = "loose";

      # trustedInterfaces = "tailscale0" # TODO
    };
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    wg-quick.interfaces = {
      wg-baczek = {
        # Bridge server iface 10.10.0.1
        address = [ "10.10.0.5/24" ];
        listenPort = 20001;

        privateKeyFile = "/root/wireguard-keys/wg-baczek/private";

        peers = [
          {
            publicKey = "7cIMQcZ6AackXV2RaLkC5cqmAVGd1PXnO4wGVcdcWkY=";
            allowedIPs = [ "10.10.0.0/24" ];
            endpoint = "baczek.me:20001";
            persistentKeepalive = 25;
          }
          {
            publicKey = "kbznnxqKi36faGajgwpdBpWFYcj6yCyUmCQJXg1pFzc=";
            allowedIPs = [ "10.10.0.3/32" ];
          }
        ];
      };
    };
  };

  services.borgbackup.repos = {
    baczek = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILulC22JoRPoRtU5Q36cMzwo8W3DA2l58MUu9VcQEghw wint3rmute@thinkcentre"
      ];
      path = "/mnt/backup/baczek";
      quota = "100G";
      allowSubRepos = true;
    };

    kube-01 = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8itVsInt/KzsOTn1BqmjuDfgR5IIPuN4nT6g1JVrVt root@kube-01"
      ];
      path = "/mnt/backup/kube-01";
      quota = "220G";
      allowSubRepos = true;
    };
  };

  services.ntfy-sh = {
    enable = false;
    settings = {
      listen-http = "127.0.0.1:8001";
      base-url = "https://ntfy.${config.networking.hostName}.${config.networking.domain}";
      auth-default-access = "deny-all";
    };
  };

  services.traefik = {
    enable = true;

    environmentFiles = [ config.age.secrets."traefik.env".path ];

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http3 = { };
          http.tls.certResolver = "letsencrypt";
          transport = {
            respondingTimeouts = {
              readTimeout = "0s";
            };
          };
        };

        # ntp = { address = ":123/udp"; };
      };

      log = {
        level = "DEBUG";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        # Comment for prod
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
        email = "majabojarska98@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "ovh";
          disablePropagationCheck = true;
          delayBeforeCheck = 120;
        };
      };

      api.dashboard = false;
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      # api.insecure = true;
    };

    dynamicConfigOptions.http = {
      routers = {
        ntfy = {
          rule = "Host(`ntfy.${config.networking.hostName}.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "ntfy";
          # TODO: Is this needed?
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "ntfy.${config.networking.hostName}.${config.networking.domain}";
              }
            ];
          };
        };

        blog = {
          rule = "Host(`majabojarska.dev`)";
          service = "blog";
          tls = {
            certResolver = "letsencrypt";
            domains = [{ main = "majabojarska.dev"; }];
          };
          middlewares = [ "compress_response" ];
        };

        copyparty = {
          rule = "Host(`copyparty.cloud.majabojarska.dev`)";
          service = "copyparty";
          tls = {
            certResolver = "letsencrypt";
            domains = [{ main = "copyparty.cloud.majabojarska.dev"; }];
          };
          middlewares = [ "compress_response" ];
        };

        fibo = {
          rule = "Host(`fibo.cloud.majabojarska.dev`)";
          service = "fibo";
          tls = {
            certResolver = "letsencrypt";
            domains = [{ main = "fibo.cloud.majabojarska.dev"; }];
          };
          middlewares = [
            "compress_response"
            "rate_limit"
            "fibo_redirect_swagger"
          ];
        };
      };
      middlewares = {
        compress_response = {
          compress = { };
        };
        rate_limit = {
          rateLimit = {
            average = 10;
            period = "1s";
            burst = 20;
          };
        };
        fibo_redirect_swagger = {
          redirectRegex = {
            regex = "^https://fibo\.cloud\.majabojarska\.dev/(swagger)?$";
            replacement = "https://fibo.cloud.majabojarska.dev/swagger/index.html";
          };
        };
      };
      services = {
        # TODO: Re-enable once auth is figured out
        ntfy.loadBalancer = {
          passHostHeader = true;
          servers = [
            {
              url = "http://" + builtins.toString config.services.ntfy-sh.settings.listen-http;
            }
          ];
        };

        blog.loadBalancer = {
          servers = [
            {
              url =
                "http://"
                + (builtins.elemAt config.services.nginx.virtualHosts."majabojarska.dev".listen 0).addr
                + ":"
                +
                builtins.toString
                  (builtins.elemAt config.services.nginx.virtualHosts."majabojarska.dev".listen 0).port;
            }
          ];
        };

        copyparty.loadBalancer = {
          servers = [
            {
              url =
                "http://"
                + config.services.copyparty.settings.i
                + ":"
                + builtins.toString (builtins.elemAt config.services.copyparty.settings.p 0);
            }
          ];
        };

        fibo.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:8006";
            }
          ];
        };
      };
    };
  };

  # Blog
  services.nginx.enable = true;
  services.nginx.virtualHosts."majabojarska.dev" = {
    serverName = "majabojarska.dev";
    root = "/var/www/majabojarska.dev";

    locations."/" = {
      tryFiles = "$uri $uri/ /404.html";
      index = "index.html";
    };

    listen = [
      {
        addr = "127.0.0.1";
        port = 8004;
      }
    ];

    extraConfig = ''
      access_log /var/log/nginx/majabojarska.dev.access.log ;
      absolute_redirect off ;
    '';
  };

  # https://github.com/9001/copyparty?tab=readme-ov-file#nixos-module
  services.copyparty = {
    enable = true;
    # the user to run the service as
    user = "copyparty";
    # the group to run the service as
    group = "copyparty";
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {
      i = "127.0.0.1";
      # use lists to set multiple values
      p = [
        8005
      ];
      # use booleans to set binary flags
      no-reload = false;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
      xff-src = "127.0.0.1"; # IP of the reverse proxy
      xff-hdr = "x-forwarded-for"; # HTTP header containing the real client's IP
      rproxy = 1;
    };

    # create users
    accounts = {
      maja = {
        passwordFile = config.age.secrets."copyparty-pass-maja".path;
      };
      baczek = {
        passwordFile = config.age.secrets."copyparty-pass-baczek".path;
      };
    };

    # create a group
    groups = {
      admins = [
        "maja"
      ];
      users = [
        "maja"
        "baczek"
      ];
    };

    # create a volume
    volumes = {
      # create a volume at "/" (the webroot), which will
      "/" = {
        # share the contents of "/srv/copyparty"
        path = "/mnt/storage/copyparty";
        # see `copyparty --help-accounts` for available options
        access = {
          # everyone gets read-access, but
          # r = "*";
          # users "ed" and "k" get read-write
          rw = [
            "maja"
            "baczek"
          ];
        };
        # see `copyparty --help-flags` for available options
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        fibo = {
          image = "majabojarska/fibo:0.0.3";
          ports = [
            "127.0.0.1:8006:8006"
          ];
          environment = {
            POSTGRESS_PASSWORD = "password";
            FIBO_DEBUG = "false";
            FIBO_API_ADDR = "0.0.0.0:8006";
            FIBO_API_ROOT_URL = "https://fibo.cloud.majabojarska.dev";
            FIBO_API_ALLOW_ORIGINS = "https://fibo.cloud.majabojarska.dev";
            FIBO_METRICS_ENABLED = "true";
            FIBO_METRICS_ADDR = "0.0.0.0:8006";
            FIBO_METRICS_PATH = "/metrics";
            FIBO_LOGGING_LEVEL = "info";
          };
        };
      };
    };
  };

  services.chrony = {
    enable = true;
    extraConfig = ''
      allow all
    '';
    servers = [
      "ntp2.301-moved.de" # Wuppertal
      "ntp2.rueckgr.at" # Nuremberg
      "stratum2-3.NTP.TechFak.Uni-Bielefeld.DE" # Bielefeld
      "time.hueske-edv.de" # Falkenstein
      "ntp0.hochstaetter.de" # Munich
    ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
