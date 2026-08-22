{ pkgs, ... }: {
  systemd.user.services."servers-healthcheck" = {
    Unit = {
      Description = "Check endpoints health";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "servers-healthcheck" ''
        #!/usr/bin/env bash
        set -uo pipefail

        LOG="$HOME/.local/state/servers-healthcheck.log"
        mkdir -p "$(dirname "$LOG")"

        host1=$(cat /run/secrets/server1)
        host2=$(cat /run/secrets/server2)
        sig=$(cat /run/secrets/server-sig)

        fail=0
        for h in "$host1" "$host2" "api.$host1" "api.$host2"; do
          sleep 0.2
          resp=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://$h/api/payment/callback" \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode "data=eyJvcmRlcl9pZCI6InRlc3QiLCJzdGF0dXMiOiJzdWNjZXNzIiwiYW1vdW50IjoxLCJjdXJyZW5jeSI6IlVTRCIsImFjdGlvbiI6InBheSJ9" \
            --data-urlencode "signature=$sig")
          if [[ "$resp" != 2* ]]; then
            fail=1
            echo "$(date -Iseconds) host=$h status=$resp" >> "$LOG"
          fi
        done

        if [[ "$fail" -eq 1 ]]; then
          ${pkgs.libnotify}/bin/notify-send \
            -u critical \
            "🔴 Server healthcheck failing"
        fi
      '';
    };
  };

  systemd.user.timers."servers-healthcheck" = {
    Unit = {
      Description = "Check server health";
      PartOf = [ "graphical-session.target" ];
    };

    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "6h";
      Unit = "servers-healthcheck.service";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
