{ pkgs, ... }:

{
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

  services.qemuGuest.enable = true;
}
