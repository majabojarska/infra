{ ... }:

{
  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # fileSystems."/mnt/backup" = {
  #   device = "/dev/disk/by-id/scsi-0Linode_Volume_Backups";
  #   fsType = "ext4";
  #   options = [
  #     # If you don't have this options attribute, it'll default to "defaults"
  #     # boot options for fstab. Search up fstab mount options you can use
  #     "defaults"
  #     "noatime"
  #     "nofail" # Prevent system from failing if this drive doesn't mount
  #   ];
  #   noCheck = true;
  #   autoResize = true;
  # };
  #
  # fileSystems."/mnt/storage" = {
  #   device = "/dev/disk/by-id/scsi-0Linode_Volume_Storage";
  #   fsType = "ext4";
  #   options = [
  #     # If you don't have this options attribute, it'll default to "defaults"
  #     # boot options for fstab mount options you can use
  #     "defaults"
  #     "noatime"
  #     "nofail" # Prevent system from failing if this drive doesn't mount
  #   ];
  #   noCheck = true;
  #   autoResize = true;
  # };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest
}
