{config, ...}:
{
  # networking.firewall = {
  #   allowedTCPPorts = [
  #     139
  #     445
  #   ];
  #   allowedUDPPorts = [
  #     137
  #     138
  #   ];
  # };

  services.samba = {
    enable = true;

    winbindd.enable = false;
    securityType = "user";
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "BEEHIVE";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.0. 10.10. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      "media" = {
        "path" = "/storage/media";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };

      "mirror-shared" = {
        "path" = "/storage/mirror/"
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      }
    };
  };

}
