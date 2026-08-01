{
  # pkgs,
  pkgs_unstable,
  config,
  ...
}:
let
  pathPaperless = "/storage/kubernetes/paperless/";
  pathData = "${pathPaperless}/data";
  pathConsumption = "${pathPaperless}/consumption";
  pathMedia = "${pathPaperless}/media";
in
{
  age.secrets = {
    "paperless-env" = {
      file = ../../secrets/paperless.env.age;
      mode = "0400";
      owner = "paperless";
      group = "paperless";
    };
  };

  users = {
    users = {
      paperless = {
        isSystemUser = true;
        extraGroups = [ "paperless" ];
        group = "paperless";
        description = "Paperless-ng";
      };
    };

    groups = {
      paperless = { };
    };
  };

  services.paperless = {
    enable = true;
    package = pkgs_unstable.paperless-ngx;

    address = "127.0.0.1";
    port = config.hosts.kube01.ports.paperless;
    domain = "paperless.${config.globals.homeDomain}";

    user = "paperless";

    configureTika = true;
    configureNginx = false;

    mediaDir = pathMedia;
    dataDir = pathData;
    consumptionDir = pathConsumption;

    environmentFile = config.age.secrets."paperless-env".path;

    settings = {
      # https://docs.paperless-ngx.com/configuration
      PAPERLESS_OCR_LANGUAGES = "pol eng";

      PAPERLESS_TIME_ZONE = config.time.timeZone;

      PAPERLESS_SESSION_COOKIE_AGE = 90 * 24 * 60 * 60; # 90 days

      PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 42; # All the dates please

      PAPERLESS_OCR_USER_ARGS = builtins.toJSON {
        optimize = 2;
        pdfa_image_compression = "auto";
        # Doesn't do anything because GhostScript compresses down to q=95
        # anyways; this serves to not degrade quality further
        jpeg_quality = 100;

        # Paperless refuses to handle signed PDFs (i.e. Docusign) by default
        # because its OCR would invalidate the signature. Since paperless keeps
        # originals however, this is of no relevance to me.
        # https://github.com/paperless-ngx/paperless-ngx/discussions/4830
        invalidate_digital_signatures = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathPaperless} 0750 paperless paperless -"
    "d ${pathData} 0750 paperless paperless -"
    "d ${pathData}/index 0750 paperless paperless -"
    "d ${pathConsumption} 0750 paperless paperless -"
    "d ${pathMedia} 0750 paperless paperless -"
  ];
}
