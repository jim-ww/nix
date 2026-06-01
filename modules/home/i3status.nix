{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [pavucontrol];

  # https://github.com/greshake/i3status-rust/blob/master/doc/themes.md
  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;
    bars = {
      main = {
        icons = "material-nf";
        theme = "ctp-mocha";
        settings = {
          theme = {
            theme = "ctp-mocha";
            overrides = {
              idle_bg = "#343845";
              idle_fg = "#abcdef";
            };
          };
        };

        blocks = [
          # {
          #   block = "custom";
          #   command = ''curl -s -f -o /dev/null "$(cat /run/secrets/server1-url)" && echo "🟢 srv" || echo "🔴 srv"'';
          #   interval = 60;
          # }
          {
            block = "music";
            format = " $icon {$combo.str(max_w:30) |}"; # rot_interval:0.5
            player = [
              "mpd"
              "firefox"
              "chromium"
            ];
            separator = " - ";
            seek_step_secs = 5;
            volume_step = 2;
            click = [
              {
                button = "left";
                cmd = "mpc toggle";
              }
              {
                button = "right";
                cmd = "mpc next";
              }
              {
                button = "middle";
                cmd = config.music-player;
              }
            ];
          }
          {
            block = "sound";
            format = "󰕾 {$volume.eng(w:2) |}";
            step_width = 2;
            click = [
              {
                button = "left";
                cmd = "pavucontrol --tab=3";
              }
            ];
          }
          # {
          #   block = "net";
          #   format = " $icon $signal_strength ";
          # }
          {
            block = "cpu";
            interval = 5;
            format = " $utilization";
          }
          {
            block = "memory";
            format = "󰍛 $mem_used_percents.eng(w:1)";
            interval = 30;
            warning_mem = 70;
            critical_mem = 85;
          }
          {
            block = "time";
            interval = 1;
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          }
          {
            block = "battery";
            interval = 7;
            full_threshold = 100;
            format = " $percentage ";
            charging_format = " $percentage ";
            full_format = " 󱩰 ";
          }
          # {
          #   block = "vpn";
          #   driver = "mullvad";
          #   format_connected = "VPN 󱜠 ";
          #   format_disconnected = "VPN  ";
          #   state_connected = "good";
          #   state_disconnected = "warning";
          # }
        ];
      };
    };
  };
}
