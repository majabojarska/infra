{ config, pkgs, ... }:
{
  age.secrets."samba-maja-password" = {
    file = ../../secrets/samba-maja-password.age;
    mode = "0400";
  };

  services.samba = {
    enable = true;

    winbindd.enable = false;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "BEEHIVE";
        "server string" = "kube-01";
        "netbios name" = "KUBE-01";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.1. 192.168.0. 10.10. 127.0.0.1 localhost";
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
        # "force user" = "username";
        # "force group" = "groupname";
      };

      "mirror" = {
        "path" = "/storage/mirror/";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        # "force user" = "username";
        # "force group" = "groupname";
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.samba-password-maja = {
    description = "Provision the Samba password for maja";
    wantedBy = [ "multi-user.target" ];
    after = [ "samba-smbd.service" ];
    requires = [ "samba-smbd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "provision-samba-password-maja" ''
        set -eu
        password_file=${config.age.secrets."samba-maja-password".path}
        password=$(cat "$password_file")

        if ${pkgs.samba}/bin/pdbedit -L | ${pkgs.gnugrep}/bin/grep -q '^maja:'; then
          printf '%s\n%s\n' "$password" "$password" | ${pkgs.samba}/bin/smbpasswd -s maja
        else
          printf '%s\n%s\n' "$password" "$password" | ${pkgs.samba}/bin/smbpasswd -a -s maja
        fi
      '';
    };
  };

}
