{ pkgs, ... }:

let
  sshKeys = import ../../../modules/ssh-keys.nix;
in

{
  boot = {
    initrd = {
      verbose = true;
      kernelModules = [ ];
      luks.devices = {
        "luks-af1757e6-0789-4cd6-99aa-311e7b6ae5cf".device =
          "/dev/disk/by-uuid/af1757e6-0789-4cd6-99aa-311e7b6ae5cf";
      };
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
        "virtio_net"
        "virtio_pci"
      ];
      systemd = {
        network.enable = true;
        users.root.shell = "/usr/bin/systemd-tty-ask-password-agent";
      };
      network = {
        enable = true;
        flushBeforeStage2 = true;
        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = sshKeys.maja;
          # https://wiki.nixos.org/wiki/Remote_disk_unlocking
          # Host RSA key for initrd created manually
          # mkdir -p /etc/secrets/initrd
          # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
          hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
        };
      };
    };

    kernelParams = [
      "ip=dhcp"
      "console=ttyS0,115200n8"
    ];
    kernelModules = [ ];
    blacklistedKernelModules = [ "algif_aead" ];

    # Disable the upstream getty module's automatic configuration for serial-getty@
    # This prevents conflicts with our custom configuration

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    zfs.forceImportRoot = false;

    extraModulePackages = [ ];
  };

  systemd.services."serial-getty@" = {
    enable = false;
  };

  # Configure our own serial-getty@ttyS0 service
  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
    after = [ "systemd-user-sessions.service" ];
    wants = [ "systemd-user-sessions.service" ];
    serviceConfig = {
      Type = "idle";
      Restart = "always";
      Environment = "TERM=vt220";
      ExecStart = "${pkgs.util-linux}/bin/agetty --login-program ${pkgs.shadow}/bin/login --noclear --keep-baud ttyS0 115200,57600,38400,9600 vt220";
      UtmpIdentifier = "ttyS0";
      StandardInput = "tty";
      StandardOutput = "tty";
      TTYPath = "/dev/ttyS0";
      TTYReset = "yes";
      TTYVHangup = "yes";
      IgnoreSIGPIPE = "no";
      SendSIGHUP = "yes";
    };
  };
}
