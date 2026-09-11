{
  programs.sway.enable = true;
  services.speechd.enable = false; # graphical-desktop default pulls espeak-ng/mbrola-voices

  environment.loginShellInit = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      for f in /etc/profile.d/*.sh; do . "$f"; done
      exec sway
    fi
  '';

  hm =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      home = config.home.homeDirectory;
      documents = "${home}/Documents";
      term = "xdg-terminal-exec --";

      fileManager = "${term} ${lib.getExe pkgs.lf}";
      passwords = "keepassxc ${documents}/.vault.kdbx";
      notes = "${term} sh -c 'cd \"${documents}\" && exec ${config.editor} TODO.md'";
      notesAll = "${term} sh -c 'cd \"${documents}\" && exec ${config.editor} .'";
    in
    {
      home.packages = with pkgs; [
        xdg-utils
        wl-clipboard
        wf-recorder
        libnotify
        playerctl
      ];

      services.hyprpaper.enable = lib.mkForce false; # TODO:

      wayland.windowManager.sway =
        let
          mod = "Mod4";
        in
        {
          enable = true;
          package = pkgs.swayfx;
          checkConfig = false;
          wrapperFeatures.gtk = true;
          # SWAYFX
          extraConfig = ''
            corner_radius 10
            smart_corner_radius enable
            shadows on
          '';
          config = {
            modifier = mod;
            terminal = "xdg-terminal-exec";
            window.titlebar = false;
            startup = [
              { command = lib.getExe pkgs.autotiling-rs; }
              { command = "kage daemon start"; }
              { command = "keepassxc --minimized"; }
              { command = "lf -server"; }
              { command = "fcitx5"; }
            ];
            input."*" = {
              xkb_layout = "us,ru";
              xkb_options = "grp:win_space_toggle";
              xkb_numlock = "enabled";
              tap = "enabled";
              accel_profile = "flat";
              pointer_accel = "0.0";
            };
            bars = [ ];
            gaps =
              let
                val = 4;
              in
              {
                bottom = 0;
                horizontal = val;
                vertical = val;
                inner = val;
                left = 0;
                outer = 0;
                right = 0;
                top = 0;
                smartBorders = "on"; # remove coloring when single window
                smartGaps = true; # remove gaps when single window
              };
            workspaceOutputAssign = [
              {
                workspace = "1";
                output = "eDP-1";
              }
            ];
            floating = {
              border = 0;
              criteria = [
                {
                  title = "term-float";
                }
              ];
            };
            # window.commands = [];
            window.border = 1;
            bindkeysToCode = true;
            keybindings =
              let
                ipc = "noctalia msg";
              in
              {
                # basic
                "${mod}+c" = "exec swaymsg kill";
                "${mod}+Shift+m" = "exit";
                "${mod}+v" = "floating toggle";
                "${mod}+Shift+f" = "fullscreen toggle";
                "${mod}+Up" = "focus up";
                "${mod}+Down" = "focus down";
                "${mod}+Left" = "focus left";
                "${mod}+Right" = "focus right";
                "--locked Alt+Tab" = "exec ${ipc} window-switcher";
                # move windows
                "${mod}+Shift+Left" = "move left";
                "${mod}+Shift+Right" = "move right";
                "${mod}+Shift+Up" = "move up";
                "${mod}+Shift+Down" = "move down";
                # programs
                "${mod}+q" = "exec footclient";
                "${mod}+Shift+q" = "exec foot";
                "${mod}+t" = "exec footclient --title=term-float";
                "${mod}+Shift+t" = "exec ${ipc} panel-toggle launcher '/tr '";
                "${mod}+e" = "exec ${fileManager}";
                "${mod}+f" = "exec ${config.browser}";
                "${mod}+s" = "exec ${config.music-player}";
                "${mod}+Shift+s" = "exec ${ipc} panel-toggle reaperhound/ambient-sounds:main";
                "${mod}+Shift+a" = "exec ${ipc} panel-toggle control-center system";
                "${mod}+w" = "exec ${ipc} panel-toggle wallpaper";
                "${mod}+Shift+w" = "exec ${ipc} panel-toggle noctalia/wallhaven:browser";
                "${mod}+b" = "exec ${passwords}";
                "${mod}+k" = "exec ${ipc} panel-toggle launcher '/calc '";
                "${mod}+Shift+b" = "exec ${ipc} panel-toggle launcher '/web '";
                "${mod}+j" = "exec exec ${ipc} panel-toggle launcher '/kao '";
                "${mod}+x" = "exec ${notes}";
                "${mod}+Shift+x" = "exec ${notesAll}";
                "${mod}+d" = "exec ${term} ${config.editor}";
                "${mod}+z" = "exec xdg-terminal-exec -- kage";
                "${mod}+Tab" = "exec ${ipc} panel-toggle control-center";
                "${mod}+p" = "exec ${ipc} panel-toggle control-center audio";
                "${mod}+r" = "exec ${ipc} panel-toggle launcher";
                "${mod}+l" = "exec ${ipc} session lock";
                "${mod}+Shift+c" = "exec ${ipc} panel-toggle clipboard";
                "Print" = "exec ${ipc} screenshot-region";
                "${mod}+Print" = "exec ${ipc} screenshot-fullscreen";
                # toggle screen
                "${mod}+F1" = "exec ${ipc} dpms-on";
                "${mod}+F2" = "exec ${ipc} dpms-off";
                # sway-specific
                "${mod}+Shift+r" = "reload";
                # "${mod}+Shift+t" = "exec swaymsg reload_config";
                "${mod}+Shift+Escape" = "exec swaymsg input type:touchpad events toggle enabled disabled";
                # volume
                "--locked XF86AudioRaiseVolume" = "exec ${ipc} volume-up";
                "--locked XF86AudioLowerVolume" = "exec ${ipc} volume-down";
                "--locked XF86AudioMute" = "exec ${ipc} volume-mute";
                # playback control
                "--locked XF86AudioPlay" = "exec playerctl -p mpd play-pause"; # ${ipc} media toggle";
                "--locked XF86AudioPause" = "exec playerctl -p mpd pause"; # ${ipc} media pause";
                "--locked XF86AudioNext" = "exec playerctl -p mpd next"; # ${ipc} media next";
                "--locked XF86AudioPrev" = "exec playerctl -p mpd previous"; # ${ipc} media previous";
                # brightness
                "--locked XF86MonBrightnessUp" = "exec ${ipc} brightness-up 10";
                "--locked XF86MonBrightnessDown" = "exec ${ipc} brightness-down 10";
                # switch workspaces
                "${mod}+1" = "workspace number 1";
                "${mod}+2" = "workspace number 2";
                "${mod}+3" = "workspace number 3";
                "${mod}+4" = "workspace number 4";
                "${mod}+5" = "workspace number 5";
                "${mod}+6" = "workspace number 6";
                "${mod}+7" = "workspace number 7";
                "${mod}+8" = "workspace number 8";
                "${mod}+9" = "workspace number 9";
                "${mod}+0" = "workspace number 10";
                # move to workspaces
                "${mod}+Shift+1" = "move container to workspace number 1";
                "${mod}+Shift+2" = "move container to workspace number 2";
                "${mod}+Shift+3" = "move container to workspace number 3";
                "${mod}+Shift+4" = "move container to workspace number 4";
                "${mod}+Shift+5" = "move container to workspace number 5";
                "${mod}+Shift+6" = "move container to workspace number 6";
                "${mod}+Shift+7" = "move container to workspace number 7";
                "${mod}+Shift+8" = "move container to workspace number 8";
                "${mod}+Shift+9" = "move container to workspace number 9";
                "${mod}+Shift+0" = "move container to workspace number 10";
              };
          };
        };
    };
}
