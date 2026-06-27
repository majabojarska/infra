{ ... }:

{
  services.anubis = {
    defaultOptions = {
      settings = {
        WEBMASTER_EMAIL = "majabojarska98@gmail.com";
        DIFFICULTY = 6;
      };

      botPolicy = {
        bots = [
          { import = "(data)/meta/default-config.yaml"; }
          { import = "(data)/bots/ai-catchall.yaml"; }
          { import = "(data)/bots/cloudflare-workers.yaml"; }
        ];
        status_codes = {
          CHALLENGE = 403;
          DENY = 403;
        };

        store.backend = "memory";

        thresholds = [
          {
            name = "no-suspicion";
            expression.all = [
              "weight < 10"
            ];
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 3;
            };
          }
          {
            name = "moderate-suspicion";
            expression.all = [
              "weight >= 10"
              "weight < 20"
            ];
            action = "CHALLENGE";
            challenge = {
              # https://anubis.techaro.lol/docs/admin/configuration/challenges/proof-of-work
              algorithm = "fast";
              difficulty = 4;
            };
          }
          {
            name = "mild-proof-of-work";
            expression.all = [
              "weight >= 20"
              "weight < 30"
            ];
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 5;
            };
          }
          {
            name = "extreme-suspicion";
            expression = "weight >= 30";
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 6;
            };
          }
        ];
      };
    };

    instances.blog.settings = {
      BIND = ":8080";
      BIND_NETWORK = "tcp";
      TARGET = " ";
      REDIRECT_DOMAINS = "majabojarska.dev";
      PUBLIC_URL = "https://anubis.cloud.majabojarska.dev";
      COOKIE_DOMAIN = "majabojarska.dev";
      DIFFICULTY = 20;
      SERVE_ROBOTS_TXT = true;
    };
  };

}
