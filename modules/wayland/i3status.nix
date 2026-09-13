{
  pkgs,
  ...
}:
let
  music-player = "foot rmpc";
  music-player-next = "mpc next";
  music-player-toggle = "mpc toggle";
  sound-controls = "pavucontrol --tab=3"; # TODO:
in
{
  home.packages = [ pkgs.mpc ];
  # https://github.com/greshake/i3status-rust/blob/master/doc/themes.md
  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;
    bars = {
      main = {
        icons = "material-nf";
        # theme = "ctp-mocha";
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
          {
            block = "music";
            format = " $icon {$combo.str(max_w:30) |}"; # rot_interval:0.5
            player = [ "mpd" ];
            separator = " - ";
            seek_step_secs = 5;
            volume_step = 2;
            click = [
              {
                button = "left";
                cmd = music-player-toggle;
              }
              {
                button = "right";
                cmd = music-player-next;
              }
              {
                button = "middle";
                cmd = music-player;
              }
            ];
          }
          {
            block = "sound";
            format = " 󰕾 {$volume.eng(w:2) |}";
            step_width = 2;
            click = [
              {
                button = "left";
                cmd = sound-controls;
              }
            ];
          }
          {
            block = "time";
            interval = 1;
            format = "  $timestamp.datetime(f:'%a %d/%m %R') ";
          }
          {
            block = "battery";
            interval = 7;
            full_threshold = 100;
            format = " $percentage ";
            charging_format = "  $percentage ";
            full_format = " 󱩰 ";
          }
        ];
      };
    };
  };
}
