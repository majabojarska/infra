{ config, ... }:
{
  imports = [
    ../../../modules/notifications.nix
  ];

  age.secrets = {
    "ntfy-token" = {
      file = ../secrets/ntfy-token.age;
      mode = "0400";
    };
  };

  majabojarska.notifications = {
    enable = true;
    tokenFile = config.age.secrets."ntfy-token".path;
    topic = "ntfy.${config.globals.cloudDomain}/power";
  };
}
