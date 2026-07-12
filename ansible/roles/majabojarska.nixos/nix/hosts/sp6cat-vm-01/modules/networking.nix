{ config, ... }:

{
  # services.tailscale = {
  #   enable = true;
  #   useRoutingFeatures = "both";
  #   openFirewall = true;
  #   disableTaildrop = true;
  #   authKeyFile = config.age.secrets."tailscale-auth-key".path;
  #   extraUpFlags = [
  #     "--accept-routes"
  #     "--advertise-exit-node"
  #   ];
  # };

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

  age.secrets = {
    "wg-beehive-priv-key" = {
      file = ../secrets/wg-beehive-priv-key.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };
    "wg-baczek-priv-key" = {
      file = ../secrets/wg-baczek-priv-key.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };

  # DNS
  services.resolved = {
    enable = false;
  };
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      "no-resolv" = true;
      "bind-interfaces" = true;
      "listen-address" = "127.0.0.1";
      server = [
        "/home.majabojarska.dev/192.168.1.1"
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };
  networking = {
    nameservers = [ "127.0.0.1" ];

    networkmanager = {
      dns = "none";
    };
  };

  networking = {
    hostName = "sp6cat-vm-01";
    domain = config.globals.cloudDomain;
    hostId = "529617af"; # First 8 chars from /etc/machine-id

    firewall = {
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [
        20000 # wg-beehive wireguard
        20001 # wg-baczek wireguard
        123 # NTP
        443 # HTTP3
      ];
      checkReversePath = "loose";
      trustedInterfaces = [
        "wg-baczek"
      ];
    };
    usePredictableInterfaceNames = true;
    useDHCP = true;

    wg-quick.interfaces = {
      wg-beehive = {
        address = [
          "10.1.0.1/24"
        ];
        listenPort = 20000;
        mtu = 1420;

        privateKeyFile = config.age.secrets."wg-beehive-priv-key".path;

        peers = [
          {
            # OPNsense
            publicKey = "PrSlPauZMQ1nMxKHxFfKr8mnrzjBOjSoX9d6B8z01V4=";
            allowedIPs = [
              "10.1.0.2/32"
              "192.168.1.0/24"
            ];
          }
        ];

      };
      wg-baczek = {
        address = [ "10.10.0.1/24" ];
        listenPort = 20001;
        mtu = 1420;

        privateKeyFile = config.age.secrets."wg-baczek-priv-key".path;

        peers = [
          {
            publicKey = "kbznnxqKi36faGajgwpdBpWFYcj6yCyUmCQJXg1pFzc=";
            allowedIPs = [ "10.10.0.3/32" ];
          }
        ];
      };
    };
  };
}
