{ config, lib, pkgs, ... }:
let
  cfg = config.majabojarska.notifications;
in
{
  options.majabojarska.notifications = {
    enable = lib.mkEnableOption "startup/shutdown ntfy notifications";

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing an ntfy access token.";
    };

    topic = lib.mkOption {
      type = lib.types.str;
      default = "ntfy.${config.globals.cloudDomain}/power";
      description = "ntfy topic to publish startup/shutdown notifications to.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tokenFile != null;
        message = "majabojarska.notifications.tokenFile must be set when notifications are enabled.";
      }
    ];

    environment.systemPackages = [ pkgs.ntfy-sh ];

    systemd.services.notify-startup-shutdown = {
      description = "Send notifications on startup and shutdown";
      wantedBy = [ "multi-user.target" ];
      before = [ "shutdown.target" ];
      unitConfig = {
        ConditionPathExists = "!/run/notify-startup-sent";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "notify-startup" ''
          NTFY_TOKEN="$(cat ${cfg.tokenFile})"
          ${pkgs.ntfy-sh}/bin/ntfy publish \
            --token "$NTFY_TOKEN" \
            "${cfg.topic}" \
            "${config.networking.hostName} has started up"
        '';
        ExecStartPost = "${pkgs.coreutils}/bin/touch /run/notify-startup-sent";
        ExecStop = pkgs.writeShellScript "notify-shutdown" ''
          NTFY_TOKEN="$(cat ${cfg.tokenFile})"
          ${pkgs.ntfy-sh}/bin/ntfy publish \
            --token "$NTFY_TOKEN" \
            "${cfg.topic}" \
            "${config.networking.hostName} is shutting down"
        '';
      };
    };
  };
}
