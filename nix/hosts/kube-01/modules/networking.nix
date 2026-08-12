{ config, ... }:

{
  systemd.network.wait-online.enable = false;

  networking = {
    hostName = "kube-01";
    domain = config.globals.homeDomain;
    hostId = "132aea15"; # First 8 chars from /etc/machine-id

    networkmanager.enable = true;
    interfaces.ens18.useDHCP = true;

    usePredictableInterfaceNames = true;
    firewall = {
      trustedInterfaces = [
        "ens18"
        "tailscale0"
        "cni0"
      ];

      allowedTCPPorts = [
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
}
