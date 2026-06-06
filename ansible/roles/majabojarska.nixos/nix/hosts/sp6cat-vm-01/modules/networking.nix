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

  networking = {
    hostName = "sp6cat-vm-01";
    domain = "cloud.majabojarska.dev";
    hostId = "529617af"; # First 8 chars from /etc/machine-id

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
      trustedInterfaces = [
        "wg-baczek"
      ];
    };
    usePredictableInterfaceNames = false;
    useDHCP = true;
    # interfaces.eth0.useDHCP = true;

    wg-quick.interfaces = {
      wg-baczek = {
        # Bridge server iface 10.10.0.1
        address = [ "10.10.0.1/24" ];
        listenPort = 20001;

        privateKeyFile = config.age.secrets."wg-baczek-priv-key".path;

        peers = [
          # {
          #   publicKey = "7cIMQcZ6AackXV2RaLkC5cqmAVGd1PXnO4wGVcdcWkY=";
          #   allowedIPs = [ "10.10.0.0/24" ];
          #   endpoint = "baczek.me:20001";
          #   persistentKeepalive = 25;
          # }
          {
            publicKey = "kbznnxqKi36faGajgwpdBpWFYcj6yCyUmCQJXg1pFzc=";
            allowedIPs = [ "10.10.0.3/32" ];
          }
        ];
      };
    };
  };
}
