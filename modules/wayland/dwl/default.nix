{
  pkgs,
  config,
  lib,
  ...
}:
let
  home = "/home/${config.user}";
  documents = "${home}/Documents";

  term = "foot";
  shell = "${pkgs.busybox}/bin/sh";

  cCmd = args: "CMD(${lib.concatMapStringsSep ", " builtins.toJSON args})";

  screenshotTo = ''"${home}/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"'';
  screenshotPipe = "${pkgs.coreutils}/bin/tee ${screenshotTo} | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} -t image/png";

  screenshot = [
    shell
    "-c"
    ''geometry="$(${lib.getExe pkgs.slurp})" || exit 1; ${lib.getExe pkgs.grim} -g "$geometry" - | ${screenshotPipe}''
  ];

  screenshotFull = [
    shell
    "-c"
    "${lib.getExe pkgs.grim} - | ${screenshotPipe}"
  ];

  fileManager = [
    term
    (lib.getExe pkgs.lf)
  ];

  resourceMonitor = [
    term
    "btop"
  ];

  passwords = [
    "keepassxc"
    "${documents}/.vault.kdbx"
  ];

  bookmarks = [
    shell
    "-c"
    "${lib.getExe pkgs.yq-go} -r '.[]' /run/secrets/bookmarks | ${lib.getExe pkgs.bemenu} -i -p bookmarks | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
  ];

  clipboard = [
    shell
    "-c"
    "cliphist list | bemenu | cliphist decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
  ];

  kaomojiRepo = pkgs.fetchFromGitHub {
    owner = "jim-ww";
    repo = "kaomoji-csv";
    rev = "9c7d5bbcc968cb9f2d077ed8dfeeabbd0b3b4c1a";
    hash = "sha256-TnFvZWURAjUbtz8YBoaLsNYHLinC+urR/N2xPyJbLLM=";
  };

  kaomojiData = "${kaomojiRepo}/kaomoji.csv";

  kaomoji = pkgs.writeShellScriptBin "kaomoji" ''
    ${lib.getExe pkgs.bemenu} -i -p kaomoji --width-factor 0.4 < ${kaomojiData} |
      awk '{print $1}' |
      sed 's/\\xc2\\xa0/ /g' |
      ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
  '';

  notes = [
    term
    "sh"
    "-c"
    "cd ${documents} && exec ${config.editor} TODO.md"
  ];

  notesAll = [
    term
    "sh"
    "-c"
    "cd ${documents} && exec ${config.editor} ."
  ];

  wallpaper = pkgs.writeShellScriptBin "dwl-wallpaper" ''
    ${lib.getExe pkgs.swaybg} -i "$NH_FLAKE/wallpaper" -m fill &
    disown
  '';

  wallpaper-selector = null;

  calculator = [
    term
    shell
    "-c"
    "echo calc; exec ${lib.getExe pkgs.bc} -q"
  ];

  launcher = pkgs.writeShellScriptBin "launcher" ''
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT

    # Format: <display>|<command>|<kind>
    # kind is "gui" (run directly) or "term" (run inside foot)

    {
      printf '%s|%s|%s\n' "Terminal"     "${term}"                                                        "gui"

      for f in /run/current-system/sw/share/applications/*.desktop \
               "$HOME"/.nix-profile/share/applications/*.desktop; do
        [ -e "$f" ] || continue
        name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
        exec_cmd=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | sed 's/ *%[fFuUdDnNickvm]//g')
        [ -n "$name" ] && [ -n "$exec_cmd" ] && printf '%s|%s|%s\n' "$name" "$exec_cmd" "gui"
      done

      compgen -c 2>/dev/null | sort -u | while read -r cmd; do
        [ -n "$cmd" ] && printf '%s|%s|%s\n' "$cmd" "$cmd" "term"
      done
    } > "$tmp"

    choice=$(cut -d'|' -f1 "$tmp" | ${lib.getExe pkgs.bemenu} -i -p run --list 15)
    [ -n "$choice" ] || exit 0

    line=$(awk -F'|' -v choice="$choice" '$1 == choice { print; exit }' "$tmp")

    if [ -n "$line" ]; then
      cmd=$(printf '%s\n' "$line" | cut -d'|' -f2)
      kind=$(printf '%s\n' "$line" | cut -d'|' -f3)
    else
      # Not in the list — treat whatever the user typed as a raw shell command.
      cmd="$choice"
      kind="term"
    fi

    if [ "$kind" = "gui" ]; then
      exec sh -c "$cmd"
    else
      exec ${term} -e sh -c "$cmd"
    fi
  '';

  audioOutputSelect = [
    shell
    "-c"
    "choice=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '[0-9]+\\.' | ${lib.getExe pkgs.bemenu} -p output)"
  ];

  screenlock = [
    shell
    "-c"
    "${lib.getExe pkgs.swaylock} -efkli ${config.flakeDir}/wallpaper && ${config.shellAliases.umount-personal}"
  ];

  screenOn = null;
  screenOff = null;

  volumeUp = [
    "sh"
    "-c"
    "pamixer -i 5 && pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock"
  ];
  volumeDown = [
    "sh"
    "-c"
    "pamixer -d 5 && pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock"
  ];
  volumeMute = [
    "sh"
    "-c"
    "pamixer -t && (pamixer --get-mute && echo 0 || pamixer --get-volume) > $XDG_RUNTIME_DIR/wob.sock"
  ];
  brightnessUp = [
    "sh"
    "-c"
    "brightnessctl s +10% | sed -n 's/.*(\\([0-9]*\\)%).*/\\1/p' > $XDG_RUNTIME_DIR/wob.sock"
  ];
  brightnessDown = [
    "sh"
    "-c"
    "brightnessctl s 10%- | sed -n 's/.*(\\([0-9]*\\)%).*/\\1/p' > $XDG_RUNTIME_DIR/wob.sock"
  ];

  translator = null;

  effects = true;

  layout = "btrtile";

  layoutIndex =
    {
      tile = 0;
      floating = 1;
      monocle = 2;
      btrtile = 3;
    }
    .${layout};

  base16 = config.lib.stylix.colors;

  configH = ''
    #define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                            ((hex >> 16) & 0xFF) / 255.0f, \
                            ((hex >> 8) & 0xFF) / 255.0f, \
                            (hex & 0xFF) / 255.0f }

    static const int sloppyfocus               = 1;
    static const int bypass_surface_visibility = 0;
    static const unsigned int borderpx         = 3;
    static const unsigned int gappx            = 4;
    static int gaps                            = 1;
    static const int smartgaps                 = 1;
    static const int smartborders              = 1;
    static const float resize_factor           = 0.0004f;
    static const uint32_t resize_interval_ms   = 25;
    static int enableautoswallow               = 1;
    static float swallowborder                 = 1.0f;

    enum Direction { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN };
    static const float rootcolor[]             = COLOR(0x${base16.base00}ff);
    static const float bordercolor[]           = COLOR(0x${base16.base03}ff);
    static const float focuscolor[]            = COLOR(0x${base16.base0C}ff);
    static const float urgentcolor[]           = COLOR(0x${base16.base08}ff);
    static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

    ${lib.optionalString effects ''
      static const int opacity = 0;
      static const float opacity_inactive = 0.5;
      static const float opacity_active = 1.0;

      static const int shadow = 1;
      static const int shadow_only_floating = 0;
      static const float shadow_color[4] = COLOR(0x000000aa);
      static const float shadow_color_focus[4] = COLOR(0x000000aa);
      static const int shadow_blur_sigma = 15;
      static const int shadow_blur_sigma_focus = 15;
      static const char *const shadow_ignore_list[] = { NULL };

      static const int corner_radius = 10;
      static const int corner_radius_inner = 9;
      static const int corner_radius_only_floating = 0;

      static const int blur = 0;
      static const int blur_xray = 0;
      static const int blur_ignore_transparent = 1;
      static const struct blur_data blur_data = {
          .radius = 5,
          .num_passes = 3,
          .noise = (float)0.02,
          .brightness = (float)0.9,
          .contrast = (float)0.9,
          .saturation = (float)1.1,
      };
    ''}

    #define TAGCOUNT (10)

    static int log_level = WLR_ERROR;

    static const Rule rules[] = {
        /* app_id             title       tags mask     isfloating   isterm   noswallow   monitor */
        { "foot",             NULL,       0,            0,           1,           0,          -1 },
        { NULL,               "term-float", 0,            1,           -1 },
    };

    static const Layout layouts[] = {
        { "[]=",      tile },
        { "><>",      NULL },
        { "[M]",      monocle },
        { "|w|",      btrtile },
    };

    static const MonitorRule monrules[] = {
        { NULL,       0.55f, 1,      1,    &layouts[${toString layoutIndex}], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
    };

    static const struct xkb_rule_names xkb_rules = {
        .layout = "us,ru",
        .options = "grp:win_space_toggle",
    };

    static const int repeat_rate = 25;
    static const int repeat_delay = 600;

    static const int tap_to_click = 1;
    static const int tap_and_drag = 1;
    static const int drag_lock = 1;
    static const int natural_scrolling = 0;
    static const int disable_while_typing = 1;
    static const int left_handed = 0;
    static const int middle_button_emulation = 0;
    static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
    static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
    static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
    static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT;
    static const double accel_speed = 0.0;
    static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

    #define MODKEY WLR_MODIFIER_LOGO
    #define SHIFT  WLR_MODIFIER_SHIFT
    #define ALT    WLR_MODIFIER_ALT
    #define CTRL   WLR_MODIFIER_CTRL

    #define CMD(...) { .v = (const char*[]){ __VA_ARGS__, NULL } }

    #define TAGKEYS(KEY,TAG) \
        { MODKEY,       KEY, view,       {.ui = 1 << TAG} }, \
        { MODKEY|CTRL,  KEY, toggleview, {.ui = 1 << TAG} }, \
        { MODKEY|SHIFT, KEY, tag,        {.ui = 1 << TAG} }, \
        { MODKEY|CTRL|SHIFT, KEY, toggletag, {.ui = 1 << TAG} }

    static const Key keys[] = {
        { MODKEY,       XKB_KEY_c,          killclient,       {0} },
        { MODKEY|SHIFT, XKB_KEY_m,          spawn,            CMD("sh", "-c", "touch \"''${XDG_RUNTIME_DIR}/dwl-stop\"; loginctl terminate-session \"$XDG_SESSION_ID\" 2>/dev/null; kill -TERM $PPID") },
        { MODKEY|SHIFT, XKB_KEY_r,          quit,             {0} },
        { MODKEY,       XKB_KEY_v,          togglefloating,   {0} },
        { MODKEY|SHIFT, XKB_KEY_f,          togglefullscreen, {0} },

        { MODKEY,       XKB_KEY_Left,       focusdir,         {.ui = 0} },
        { MODKEY,       XKB_KEY_Right,      focusdir,         {.ui = 1} },
        { MODKEY,       XKB_KEY_Up,         focusdir,         {.ui = 2} },
        { MODKEY,       XKB_KEY_Down,       focusdir,         {.ui = 3} },

        { MODKEY,       XKB_KEY_Return,     zoom,             {0} },

        { MODKEY,       XKB_KEY_g,          setlayout,        {.v = &layouts[0]} },
        { MODKEY,       XKB_KEY_n,          setlayout,        {.v = &layouts[3]} },

        { MODKEY|SHIFT, XKB_KEY_Up,         swapclients,      {.ui = DIR_UP} },
        { MODKEY|SHIFT, XKB_KEY_Down,       swapclients,      {.ui = DIR_DOWN} },
        { MODKEY|SHIFT, XKB_KEY_Left,      swapclients,      {.ui = DIR_LEFT} },
        { MODKEY|SHIFT, XKB_KEY_Right,     swapclients,      {.ui = DIR_RIGHT} },

        { MODKEY|CTRL,  XKB_KEY_Left,       setratio_h,       {.f = -0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Right,      setratio_h,       {.f = +0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Up,         setratio_v,       {.f = -0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Down,       setratio_v,       {.f = +0.025f} },

        { MODKEY,       XKB_KEY_q,          spawn,            ${cCmd [ term ]} },
        { MODKEY|SHIFT, XKB_KEY_q,          spawn,            CMD("sh", "-c", "nix-shell -p st fish --run 'st fish'") },
        { MODKEY,       XKB_KEY_t,          spawn,            CMD("foot", "--title=term-float") },

        ${lib.optionalString (translator != null) ''
          { MODKEY|SHIFT, XKB_KEY_t,          spawn,            ${cCmd translator} },
        ''}

        { MODKEY,       XKB_KEY_e,          spawn,            ${cCmd fileManager} },
        { MODKEY,       XKB_KEY_f,          spawn,            ${cCmd [ config.browser ]} },
        { MODKEY,       XKB_KEY_s,          spawn,            ${
          cCmd [
            term
            "rmpc"
            "--clean"
          ]
        } },
        { MODKEY|SHIFT, XKB_KEY_a,          spawn,            ${cCmd resourceMonitor} },
        { MODKEY,       XKB_KEY_w,          spawn,            ${cCmd [ (lib.getExe wallpaper) ]} },

        ${lib.optionalString (wallpaper-selector != null) ''
          { MODKEY|SHIFT, XKB_KEY_w,          spawn,            ${cCmd wallpaper-selector} },
        ''}

        { MODKEY,       XKB_KEY_b,          spawn,            ${cCmd passwords} },
        { MODKEY,       XKB_KEY_k,          spawn,            ${cCmd calculator} },
        { MODKEY|SHIFT, XKB_KEY_b,          spawn,            ${cCmd bookmarks} },
        { MODKEY,       XKB_KEY_j,          spawn,            ${cCmd [ (lib.getExe kaomoji) ]} },
        { MODKEY,       XKB_KEY_x,          spawn,            ${cCmd notes} },
        { MODKEY|SHIFT, XKB_KEY_x,          spawn,            ${cCmd notesAll} },
        { MODKEY,       XKB_KEY_d,          spawn,            ${
          cCmd [
            term
            config.editor
          ]
        } },
        { MODKEY,       XKB_KEY_z,          spawn,            ${
          cCmd [
            term
            "kage"
          ]
        } },
        { MODKEY,       XKB_KEY_p,          spawn,            ${cCmd audioOutputSelect} },
        { MODKEY,       XKB_KEY_r,          spawn,            ${cCmd [ (lib.getExe launcher) ]} },
        { MODKEY,       XKB_KEY_l,          spawn,            ${cCmd screenlock} },
        { MODKEY|SHIFT, XKB_KEY_c,          spawn,            ${cCmd clipboard} },
        { 0,             XKB_KEY_Print,      spawn,            ${cCmd screenshot} },
        { MODKEY,        XKB_KEY_Print,      spawn,            ${cCmd screenshotFull} },

        ${lib.optionalString (screenOn != null) ''
          { MODKEY,       XKB_KEY_F1,         spawn,            ${cCmd screenOn} },
        ''}

        ${lib.optionalString (screenOff != null) ''
          { MODKEY,       XKB_KEY_F2,         spawn,            ${cCmd screenOff} },
        ''}

        { LOCKED, XKB_KEY_XF86AudioRaiseVolume,  spawn,       ${cCmd volumeUp} },
        { LOCKED, XKB_KEY_XF86AudioLowerVolume,  spawn,       ${cCmd volumeDown} },
        { LOCKED, XKB_KEY_XF86AudioMute,         spawn,       ${cCmd volumeMute} },

        { LOCKED, XKB_KEY_XF86AudioPlay,         spawn,       CMD("playerctl", "-p", "mpd", "play-pause") },
        { LOCKED, XKB_KEY_XF86AudioPause,        spawn,       CMD("playerctl", "-p", "mpd", "pause") },
        { LOCKED, XKB_KEY_XF86AudioNext,         spawn,       CMD("playerctl", "-p", "mpd", "next") },
        { LOCKED, XKB_KEY_XF86AudioPrev,         spawn,       CMD("playerctl", "-p", "mpd", "previous") },

        { LOCKED, XKB_KEY_XF86MonBrightnessUp,   spawn,       ${cCmd brightnessUp} },
        { LOCKED, XKB_KEY_XF86MonBrightnessDown, spawn,       ${cCmd brightnessDown} },

        TAGKEYS( XKB_KEY_1, 0),
        TAGKEYS( XKB_KEY_2, 1),
        TAGKEYS( XKB_KEY_3, 2),
        TAGKEYS( XKB_KEY_4, 3),
        TAGKEYS( XKB_KEY_5, 4),
        TAGKEYS( XKB_KEY_6, 5),
        TAGKEYS( XKB_KEY_7, 6),
        TAGKEYS( XKB_KEY_8, 7),
        TAGKEYS( XKB_KEY_9, 8),

        { MODKEY,       XKB_KEY_0, view, {.ui = ~0} },
        { MODKEY|SHIFT, XKB_KEY_0, tag,  {.ui = ~0} },

        { CTRL|ALT, XKB_KEY_Terminate_Server, spawn, CMD("sh", "-c", "touch \"''${XDG_RUNTIME_DIR}/dwl-stop\"; loginctl terminate-session \"$XDG_SESSION_ID\" 2>/dev/null; kill -TERM $PPID") },

    #define CHVT(n) { CTRL|ALT, XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
        CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
        CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
    };

    static const Button buttons[] = {
        { MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
        { MODKEY, BTN_MIDDLE, togglefloating, {0} },
        { MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
    };
  '';

  fcitx5 = config.i18n.inputMethod.package;

  startup = pkgs.writeShellScript "dwl-startup" (
    lib.concatStringsSep "\n" [
      "exec >>\"\${XDG_RUNTIME_DIR:-/tmp}/dwl-startup.log\" 2>&1"
      "set -x"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
      "systemctl --user start dwl-session.target"

      "${pkgs.procps}/bin/pgrep -x dwlb >/dev/null || ${lib.getExe pkgs.dwlb} -font \"monospace:size=11\" -ipc -custom-title -hide-vacant-tags -vertical-padding 0 -active-fg-color \"#${base16.base00}\" -active-bg-color \"#${base16.base0C}\" -occupied-fg-color \"#${base16.base05}\" -occupied-bg-color \"#${base16.base02}\" -inactive-fg-color \"#${base16.base03}\" -inactive-bg-color \"#${base16.base01}\" -urgent-fg-color \"#${base16.base00}\" -urgent-bg-color \"#${base16.base08}\" -middle-bg-color \"#${base16.base00}\" -middle-bg-color-selected \"#${base16.base01}\" &"

      "sleep 1"

      "${pkgs.procps}/bin/pgrep -x mako >/dev/null || ${lib.getExe pkgs.mako} &"
      "${lib.getExe pkgs.swaybg} -i ${config.flakeDir}/wallpaper -m fill &"

      ''
        i3_config="${home}/.config/i3status-rust/config-main.toml"
        log_file="''${XDG_RUNTIME_DIR:-/tmp}/i3status.log"

        if [ -f "$i3_config" ]; then
          ${pkgs.coreutils}/bin/stdbuf -oL ${lib.getExe pkgs.i3status-rust} "$i3_config" 2>>"$log_file" | \
          while IFS= read -r line; do
            status=$(echo "$line" | ${lib.getExe pkgs.jq} -r 'if type=="array" then map(.full_text // empty) | join("") else empty end' 2>/dev/null)
            if [ -n "$status" ]; then
              ${lib.getExe pkgs.dwlb} -status all "$status"
            fi
          done &
        else
          echo "i3status-rust config not found at $i3_config" >> "$log_file"
        fi
      ''

      "cliphist wipe &"
      "${pkgs.procps}/bin/pgrep -x keepassxc >/dev/null || ${lib.getExe pkgs.keepassxc} --minimized &"
      "${pkgs.procps}/bin/pgrep -f '${lib.getExe pkgs.lf} -server' >/dev/null || ${lib.getExe pkgs.lf} -server &"
      "${pkgs.procps}/bin/pgrep -x fcitx5 >/dev/null || ${lib.getExe' fcitx5 "fcitx5"} &"
      "${pkgs.procps}/bin/pgrep -x wl-clip-persist >/dev/null || ${lib.getExe' pkgs.wl-clip-persist "wl-clip-persist"} --clipboard regular &"
      "${pkgs.procps}/bin/pgrep -x polkit-mate-authentication-agent >/dev/null || ${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &"
    ]
  );

  scenefx = pkgs.scenefx.overrideAttrs (old: rec {
    version = "0.4.1";

    src = pkgs.fetchFromGitHub {
      owner = "wlrfx";
      repo = "scenefx";
      tag = version;
      hash = "sha256-XD5EcquaHBg5spsN06fPHAjVCb1vOMM7oxmjZZ/PxIE=";
    };

    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.wlroots_0_19 ];
  });

  dwl = (pkgs.dwl.override { inherit configH; }).overrideAttrs (old: {
    buildInputs =
      (old.buildInputs or [ ])
      ++ lib.optionals effects [
        scenefx
        pkgs.libGL
      ];

    patches =
      (old.patches or [ ])
      ++ [
        ./keybindings.patch
        ./gaps.patch
        ./ipc.patch
        ./btrtile.patch
        ./alwayscenter.patch
        ./focusdir.patch
        ./swallow.patch
      ]
      ++ lib.optional effects ./scenefx.patch
      ++ [ ./smartborders.patch ];
  });
in
{
  programs.dwl = {
    enable = true;

    package = pkgs.symlinkJoin {
      name = "dwl-wrapped";
      paths = [ dwl ];
      nativeBuildInputs = [ pkgs.makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/dwl --add-flags "-s '${startup}'"
      '';

      meta.mainProgram = "dwl";
    };

    extraSessionCommands = lib.concatStringsSep "\n" [
      "export XDG_CURRENT_DESKTOP=dwl"
      "export XDG_SESSION_TYPE=wayland"
      "export BEMENU_OPTS=\"--center --width-factor 0.15 --line-height 30 --border 1 --border-radius 4 --ignorecase --list 15 --prompt 'run: ' \""
    ];
  };

  services.speechd.enable = false;

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    config.dwl = lib.mkForce {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };
  };

  environment.etc."xdg/dwl-session".text = lib.mkForce ''
    #!${pkgs.runtimeShell}

    ${config.programs.dwl.extraSessionCommands}

    stopfile="''${XDG_RUNTIME_DIR:-/tmp}/dwl-stop"

    ${lib.getExe config.programs.dwl.package} \
      2>>"''${XDG_RUNTIME_DIR:-/tmp}/dwl.log"

    if [ -e "$stopfile" ]; then
      rm -f "$stopfile"
      systemctl --user stop dwl-session.target
    else
      exec /etc/xdg/dwl-session
    fi
  '';

  environment.loginShellInit = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      for f in /etc/profile.d/*.sh; do
        . "$f"
      done

      exec /etc/xdg/dwl-session
    fi
  '';

  security.pam.services.swaylock = { };

  hm =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        xdg-utils
        wl-clipboard
        wl-clip-persist
        wf-recorder
        libnotify
        playerctl
        swaybg
        brightnessctl
        dwlb
        pamixer
        bemenu
      ];

      programs.swaylock.enable = true;
    };
}
