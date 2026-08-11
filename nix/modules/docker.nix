{ ... }:

{
  virtualisation.docker = {
    enable = true;

    autoPrune = {
      enable = true;
      dates = "daily";
      persistent = true;

      allVolumes = {
        enable = true;
      };
      randomizedDelaySec = "30min";
    };
  };
}
