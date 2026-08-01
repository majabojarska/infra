{
  pkgs,
  pkgs_unstable,
  config,
  ...
}:
let
  pathImmich = "/storage/kubernetes/immich-nix/";
  pathImmichMedia = "${pathImmich}/data";
in
{
  services.immich = {
    enable = true;
    package = pkgs_unstable.immich;
    host = "127.0.0.1";
    port = config.hosts.kube01.ports.immich;
    user = "immich";
    group = "immich";
    accelerationDevices = [ "/dev/dri/render128" ];
    mediaLocation = pathImmichMedia;

    settings = {
      server = {
        externalDomain = "https://immich.${config.globals.homeDomain}";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathImmich} 0750 immich immich -"
    "d ${pathImmichMedia} 0750 immich immich -"
  ];
}
