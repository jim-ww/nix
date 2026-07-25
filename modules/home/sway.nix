{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./i3status.nix
    ./foot.nix
    ./mako.nix
    ./rofi.nix
    ./swayidle.nix
    ./cliphist.nix
  ];

  home.packages = with pkgs; [
    playerctl
    qt5.qtwayland
    swayosd
    swaybg
    grim
    slurp
    xdg-utils
    wl-clipboard
    brightnessctl
    wf-recorder
    wl-clip-persist
    libnotify
    # mpvpaper
    # morewaita-icon-theme
    # qt5.qtwayland # for QT_QPA_PLATFORM
    # wlsunset
    # pamixer
  ];

  services.swayosd.enable = true;
  programs.swaylock.enable = true;
  services.hyprpaper.enable = lib.mkForce false;

  wayland.windowManager.sway = let
    mod = "Mod4";
  in {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    xwayland = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    # SWAYFX
    extraConfig = ''
      corner_radius 10
      smart_corner_radius enable
      shadows on

      for_window [app_id="im.dino.Dino"] move scratchpad
    '';
    config = {
      modifier = mod;
      terminal = config.term;
      window.titlebar = false;
      startup = [
        {command = lib.getExe pkgs.autotiling-rs;}
        {command = config.wallpaper.command;}
        {command = "cliphist wipe";}
        {command = "wl-clip-persist --clipboard regular";}
        {command = "dino";} # "element-desktop --hidden --no-update";}
        {command = "keepassxc --minimized";}
        {command = "lf -server";}
        {command = "fcitx5";}
        {command = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";}
        {command = "protonvpn connect";}
        #{ command = "podman system service --time=0"; }
      ];
      input."*" = {
        xkb_layout = "us,ru";
        xkb_options = "grp:win_space_toggle";
        xkb_numlock = "enabled";
        tap = "enabled";
        accel_profile = "flat";
        pointer_accel = "0.0";
      };
      bars = [
        {
          fonts = {
            names = ["pango:monospace 8.000000"];
          };
          mode = "dock";
          hiddenState = "hide";
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-main.toml";
          command = "${config.wayland.windowManager.sway.package}/bin/swaybar";
          workspaceButtons = true;
          workspaceNumbers = true;
          trayOutput = "primary";
          colors = {
            background = "#000000";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              background = "#285577";
              border = "#4c7899";
              text = "#ffffff";
            };
            inactiveWorkspace = {
              background = "#222222";
              border = "#333333";
              text = "#888888";
            };
            urgentWorkspace = {
              background = "#900000";
              border = "#2f343a";
              text = "#ffffff";
            };
            bindingMode = {
              background = "#900000";
              border = "#2f343a";
              text = "#ffffff";
            };
          };
        }
      ];
      gaps = let
        val = 4;
      in {
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
            title = "Steam - Update News";
          }
          {
            title = "term-float";
          }
          {
            app_id = "org.pulseaudio.pavucontrol";
          }
          {
            title = "Profile Selection"; # unison-gui
          }
          {
            title = "Open Folder"; # gtk open dialog
          }
          {
            title = "Properties for 'Screen Capture (PipeWire)'";
          }
          {
            class = "haveno.desktop.app.HavenoApp";
          }
        ];
      };
      window.commands = [
        {
          criteria = {
            title = "Haveno-reto";
          };
          command = "floating disable";
        }
      ];
      window.border = 1;
      focus.followMouse = true;
      bindkeysToCode = true;
      keybindings = {
        # basic
        "${mod}+c" = let
          swayMsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
        in ''exec [[ $(${swayMsg} -t get_tree | ${pkgs.jq}/bin/jq -r '.. | objects | select(.focused==true) | .app_id') == "im.dino.Dino" ]] && ${swayMsg} scratchpad show && ${swayMsg} focus || ${swayMsg} kill''; # kill anything focused, but hide dino
        "${mod}+Shift+m" = "exit";
        "${mod}+v" = "floating toggle";
        "${mod}+Shift+f" = "fullscreen toggle";
        "${mod}+Up" = "focus up";
        "${mod}+Down" = "focus down";
        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        # move windows
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Down" = "move down";
        # programs
        "${mod}+q" = "exec ${config.term}";
        "${mod}+Shift+q" = "exec nix-shell -p st --run st bash";
        "${mod}+t" = "exec ${config.term} --title=term-float";
        "${mod}+e" = "exec ${config.file-manager-term}";
        "${mod}+Shift+e" = "exec ${config.file-manager}";
        "${mod}+f" = "exec ${config.browser}";
        "${mod}+s" = "exec ${config.music-player}";
        "${mod}+Shift+a" = "exec ${config.resource-monitor}";
        "${mod}+a" = "exec anki";
        "${mod}+w" = "exec freetube";
        "${mod}+b" = "exec ${config.passwords}";
        "${mod}+Shift+b" = "exec ${config.bookmarks-menu}";
        "${mod}+j" = "exec rofi -show emoji";
        "${mod}+x" = "exec ${config.notes}";
        "${mod}+Shift+x" = "exec ${config.notes-all}";
        "${mod}+d" = "exec ${config.term} ${config.editor}";
        "${mod}+z" = ''[app_id="im.dino.Dino"]scratchpad show; focus'';
        "${mod}+Shift+z" = ''[app_id="im.dino.Dino"]move scratchpad'';

        "${mod}+p" = "exec ${lib.getExe pkgs.rofi-pulse-select} sink";
        "${mod}+r" = "exec ${config.app-menu}";
        "${mod}+l" = "exec ${config.swaylock}";
        "${mod}+Shift+c" = "exec ${config.clipboard-manager}";
        "Print" = "exec ${config.screenshot} ";
        "${mod}+Print" = "exec ${config.screenshot-full}";
        # toggle screen
        "${mod}+F1" = "output eDP-1 enable";
        "${mod}+F2" = "output eDP-1 disable";
        # sway-specific
        "${mod}+Shift+r" = "reload";
        "${mod}+Shift+t" = "exec swaymsg reload_config";
        "${mod}+Escape" = "exec swaymsg input type:touchpad events toggle enabled disabled";
        # volume
        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume 2"; # "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume -2"; # "exec pamixer -d 5";
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle"; # "exec pamixer -t";
        "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle"; # "exec pamixer -t";
        # playback control
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        # brightness
        "XF86MonBrightnessUp" = "exec brightnessctl s +10 && swayosd-client --brightness raise";
        "XF86MonBrightnessDown" = "exec brightnessctl s 10- && swayosd-client --brightness lower";
        # other
        #"--release Caps_Lock" = "exec swayosd-client --caps-lock";
        "--release Num_Lock" = "exec swayosd-client --num-lock";
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
        "${mod}+Shift+0" = "move container to workpace number 10";
      };
    };
  };
}
