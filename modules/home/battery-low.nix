{ pkgs, ... }:
{
  systemd.user.services."battery-low" = {
    Unit = {
      Description = "Low battery notification (<10%)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "battery-low-notification" ''
        #!/usr/bin/env bash
        set -euo pipefail

        BAT_PATH="/org/freedesktop/UPower/devices/battery_BAT1"

        PERCENT=$(upower -i "$BAT_PATH" | grep -E "percentage:" | awk '{print $2}' | tr -d '%')
        STATE=$(upower -i "$BAT_PATH" | grep -E "state:" | awk '{print $2}')

        if [[ "$STATE" == "discharging" && "$PERCENT" -le 10 ]]; then
          ${pkgs.libnotify}/bin/notify-send \
            -u critical \
            -i battery-low \
            "🔴 Battery Low" \
            "Battery is at ''${PERCENT}% — plug in the charger now!"
        fi
      '';
    };
  };

  systemd.user.timers."battery-low" = {
    Unit = {
      Description = "Check battery level every minute";
      PartOf = [ "graphical-session.target" ];
    };

    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "battery-low.service";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
