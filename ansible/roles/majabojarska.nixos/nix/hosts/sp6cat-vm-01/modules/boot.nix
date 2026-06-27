{ config, ... }:

{
  boot = {
    initrd = {
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
          authorizedKeys = config.users.users.maja.openssh.authorizedKeys.keys;
          # https://wiki.nixos.org/wiki/Remote_disk_unlocking
          # Host RSA key for initrd created manually
          # mkdir -p /etc/secrets/initrd
          # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
          hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
        };
      };
    };

    kernelParams = [ "ip=dhcp" ];
    kernelModules = [ ];
    blacklistedKernelModules = [ "algif_aead" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    zfs.forceImportRoot = false;

    extraModulePackages = [ ];
  };
}
