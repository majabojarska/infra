{
  # pkgs,
  pkgs_unstable,
  config,
  ...
}:
let
  pathJellyfin = "/storage/kubernetes/jellyfin";
  pathJellyfinCache = "${pathJellyfin}/cache";
  pathJellyfinConfig = "${pathJellyfin}/config";
  pathJellyfinData = "${pathJellyfin}/data";
  pathJellyfinTranscoding = "${pathJellyfin}/transcoding";
in
{
  users = {
    users = {
      jellyfin = {
        isSystemUser = true;
        # isNormalUser = true;
        group = "jellyfin";
        uid = 10005;
        description = "Jellyfin user";
        extraGroups = [
          "kubernetes"
          "media"
          "video" # /dev/dri/cardX
          "render" # /dri/renderX
        ];
      };
    };

    groups.jellyfin = { };
  };

  services.jellyfin = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    cacheDir = pathJellyfinCache;
    configDir = pathJellyfinConfig;
    dataDir = pathJellyfinData;

    hardwareAcceleration = {
      enable = true;
      device = "/dev/dri/renderD128";
      type = "qsv";
    };

    transcoding = {
      # This will need tweaking fo-sho
      # Hiiii, here's a link from past Maja: https://mynixos.com/nixpkgs/options/services.jellyfin.transcoding
      enableHardwareEncoding = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathJellyfin} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinCache} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinConfig} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinData} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinTranscoding} 0750 jellyfin jellyfin -"
  ];
}
