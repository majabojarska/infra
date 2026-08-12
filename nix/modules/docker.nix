{ ... }:

{
  virtualisation.docker = {
    enable = true;

    autoPrune = {
      enable = true;
      dates = "hourly";
      persistent = true;

      allVolumes = {
        enable = true;
      };
      randomizedDelaySec = "5min";
    };
  };
}
