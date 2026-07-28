{
  pkgs,
  config,
  lib,
  ...
}:
let
  healthchecks = import ../../../../modules/healthchecks.nix { inherit lib pkgs; };
  src = pkgs.fetchFromGitHub {
    owner = "redlib-org";
    repo = "redlib";
    rev = "a4d36e954cf1bd64f209cd8868c5a29edc81b374";
    hash = "sha256-siyD6A12UALQIV7BMd7zu1TaojleTEYtpxPszuhx1/Y=";
  };
  redlib-latest = pkgs.redlib.overrideAttrs (oldAttrs: {
    version = "0.36.0-unstable-2026-04-24-vendor";
    inherit src;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "redlib-0.36.0-unstable-2026-04-24-vendor";
      hash = "sha256-eO3c7rlFna3DuO31etJ6S4c7NmcvgvIWZ1KVkNIuUqQ=";
    };
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [ ])
      ++ (with pkgs; [
        cmake
        go
        perl
        git
        rustPlatform.bindgenHook
      ]);
    checkFlags = (oldAttrs.checkFlags or [ ]) ++ [
      "--skip=oauth::tests::test_generic_web_backend"
      "--skip=oauth::tests::test_mobile_spoof_backend"
    ];
  });
in
{
  services.redlib = {
    enable = true;
    package = redlib-latest;
    address = "127.0.0.1";
    port = config.hosts.sp6catVm01.ports.redlib;
    settings = {
      REDLIB_DEFAULT_THEME = "catppuccinMocha";
      REDLIB_DEFAULT_LAYOUT = "clean";
      REDLIB_DEFAULT_WIDE = true;
      REDLIB_HOME_FROM_COLLECTIONS = "on";
    };
  };

  services.anubis.instances.redlib.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-redlib}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "redlib.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/redlib";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-redlib";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  systemd = {
    services = {
      redlib-healthcheck = {
        description = "Healthcheck for Redlib";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '
              ${pkgs.curl}/bin/curl --fail --silent http://127.0.0.1:${toString config.services.redlib.port} \
                || ${pkgs.systemd}/bin/systemctl restart redlib.service
            '
          '';
        };

      };
      redlib.serviceConfig.Restart = "always";
    };

    timers.redlib-healthcheck = {
      description = "Run myservice health check every minute";

      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "15min";
        Unit = "redlib-healthcheck.service";
      };
    };
  };

  system.preSwitchChecks = {
    redlibLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib}";
    };

    redlibDomainBlocksScrape = ''
      response=$(${pkgs.curl}/bin/curl \
        --silent \
        --write-out "%{response_code}" \
        --follow \
          https://redlib.${config.globals.cloudDomain})

      if [[ "$response" != *Anubis* ]]; then
          echo "Expected the response to contain 'Anubis', got $response"
      fi

      if [[ ! "$response" =~ 403$ ]]; then
          echo "Expected 403 response code, got \$\{response\}"
      fi
    '';
  };

}
