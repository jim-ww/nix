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

  wallpaperApply = pkgs.writeShellScriptBin "dwl-wallpaper-apply" ''
    [ -n "$1" ] && [ -f "$1" ] || exit 0
    ${pkgs.procps}/bin/pkill -x swaybg
    ${lib.getExe pkgs.swaybg} -i "$1" -m fill &
    disown
  '';

  wallpaperSet = pkgs.writeShellScriptBin "dwl-wallpaper-set" ''
    dir="${config.flakeDir}/wallpapers"
    fallback="${config.flakeDir}/wallpaper"

    pick="$fallback"
    if [ -d "$dir" ]; then
      mapfile -t files < <(find "$dir" -maxdepth 1 -type f)
      if [ "''${#files[@]}" -gt 0 ]; then
        pick="''${files[$RANDOM % ''${#files[@]}]}"
      fi
    fi

    exec ${lib.getExe wallpaperApply} "$pick"
  '';

  wallpaper = pkgs.writeShellScriptBin "dwl-wallpaper" ''
    exec ${lib.getExe wallpaperSet}
  '';

  wallpaperDaemon = pkgs.writeShellScriptBin "dwl-wallpaper-daemon" ''
    while true; do
      ${lib.getExe wallpaperSet}
      sleep 1800
    done
  '';

  dwlStatus = pkgs.writeShellScriptBin "dwl-status" ''
    set -u

    fifo="''${XDG_RUNTIME_DIR:-/tmp}/dwl-status.fifo"
    rm -f "$fifo"
    mkfifo "$fifo"
    exec 3<>"$fifo"

    order=(mpd audio time battery)
    declare -A blocks=()

    render() {
      local out="" sep=""
      for name in "''${order[@]}"; do
        local text="''${blocks[$name]:-}"
        [ -n "$text" ] || continue
        out+="''${sep}''${text}"
        sep="   "
      done
      ${lib.getExe pkgs.dwlb} -status all "$out"
    }

    update_mpd() {
      local full song state symbol text=""
      full=$(${lib.getExe pkgs.mpc} -f '%artist% - %title%' status 2>/dev/null)
      song=$(printf '%s\n' "$full" | sed -n '1p')
      if [ -n "$song" ]; then
        state=$(printf '%s\n' "$full" | sed -n '2{s/.*\[\([a-z]*\)\].*/\1/p}')
        case "$state" in
          playing) symbol=$'\uf04b' ;;
          paused) symbol=$'\uf04c' ;;
          *) symbol=$'\uf04d' ;;
        esac
        [ "''${#song}" -gt 40 ] && song="''${song:0:39}…"
        text="^lm(${lib.getExe pkgs.playerctl} -p mpd play-pause)^mm(${lib.getExe pkgs.playerctl} -p mpd previous)^rm(${lib.getExe pkgs.playerctl} -p mpd next)$symbol $song^rm()^mm()^lm()"
      fi
      printf 'mpd\t%s\n' "$text" >&3
    }

    mpd_loop() {
      while true; do
        update_mpd
        ${lib.getExe pkgs.mpc} idle player >/dev/null 2>&1 || sleep 5
      done
    }

    update_audio() {
      local vol mute label text=""
      if vol=$(${lib.getExe pkgs.pamixer} --get-volume 2>/dev/null) && [ -n "$vol" ]; then
        mute=$(${lib.getExe pkgs.pamixer} --get-mute 2>/dev/null)
        if [ "$mute" = "true" ]; then icon=$'\uf026'; label="mute"; else icon=$'\uf028'; label="''${vol}%"; fi
        text="^lm(${lib.getExe pkgs.pamixer} -t)^us(${lib.getExe pkgs.pamixer} -i 5)^ds(${lib.getExe pkgs.pamixer} -d 5)$icon $label^ds()^us()^lm()"
      fi
      printf 'audio\t%s\n' "$text" >&3
    }

    audio_loop() {
      update_audio
      ${pkgs.pulseaudio}/bin/pactl subscribe 2>/dev/null | while read -r line; do
        case "$line" in
          *sink*) update_audio ;;
        esac
      done
    }

    update_time() {
      local icon=$'\uf017'
      printf 'time\t%s %s\n' "$icon" "$(${lib.getExe' pkgs.coreutils "date"} '+%a %Y-%m-%d %H:%M')" >&3
    }

    time_loop() {
      while true; do
        update_time
        sleep 15
      done
    }

    update_battery() {
      local bat=/sys/class/power_supply/BAT0 status capacity text="" icon=$'\uf240'
      if [ -d "$bat" ]; then
        status=$(${lib.getExe' pkgs.coreutils "cat"} "$bat/status" 2>/dev/null)
        if [ "$status" = "Discharging" ]; then
          capacity=$(${lib.getExe' pkgs.coreutils "cat"} "$bat/capacity" 2>/dev/null)
          text="$icon ''${capacity}%"
        fi
      fi
      printf 'battery\t%s\n' "$text" >&3
    }

    battery_loop() {
      while true; do
        update_battery
        sleep 30
      done
    }

    mpd_loop &
    audio_loop &
    time_loop &
    battery_loop &

    while IFS=$'\t' read -r name text <&3; do
      blocks[$name]="$text"
      render
    done
  '';

  wallpaper-selector = pkgs.writeShellScriptBin "dwl-wallpaper-selector" ''
    dir="${config.flakeDir}/wallpapers"
    [ -d "$dir" ] || exit 0

    shopt -s nullglob
    files=("$dir"/*)
    [ "''${#files[@]}" -gt 0 ] || exit 0

    # dwl's session never runs xrdb, so XWayland clients (nsxiv included)
    # never see our ~/.Xresources colors without this.
    [ -r "$HOME/.Xresources" ] && ${lib.getExe pkgs.xrdb} -merge "$HOME/.Xresources"

    pick=$(${lib.getExe pkgs.nsxiv} -to "''${files[@]}" 2>/dev/null | head -n1)
    [ -n "$pick" ] || exit 0

    exec ${lib.getExe wallpaperApply} "$pick"
  '';

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

  translatorScript = pkgs.writeShellScriptBin "dwl-translate" ''
    text=$(${lib.getExe pkgs.bemenu} -p "translate:" < /dev/null)
    [ -n "$text" ] || exit 0

    if ! result=$(gtr "$text" 2>&1); then
      ${lib.getExe' pkgs.libnotify "notify-send"} -u critical "translate failed" "$result"
      exit 1
    fi

    printf '%s' "$result" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
    ${lib.getExe' pkgs.libnotify "notify-send"} "translate" "$result"
  '';

  translator = [ (lib.getExe translatorScript) ];

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
    "pamixer -t && (pamixer --get-mute >/dev/null && echo 0 || pamixer --get-volume) > $XDG_RUNTIME_DIR/wob.sock"
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

  logoutCmd = ''touch "''${XDG_RUNTIME_DIR}/dwl-stop"; loginctl terminate-session "$XDG_SESSION_ID" 2>/dev/null; kill -TERM $PPID'';

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
        { MODKEY|SHIFT, XKB_KEY_m,          spawn,            ${cCmd [ "sh" "-c" logoutCmd ]} },
        { MODKEY|SHIFT, XKB_KEY_r,          quit,             {0} },
        { MODKEY,       XKB_KEY_v,          togglefloating,   {0} },
        { MODKEY|SHIFT, XKB_KEY_f,          togglefullscreen, {0} },

        { MODKEY,       XKB_KEY_Left,       focusdir,         {.ui = 0} },
        { MODKEY,       XKB_KEY_Right,      focusdir,         {.ui = 1} },
        { MODKEY,       XKB_KEY_Up,         focusdir,         {.ui = 2} },
        { MODKEY,       XKB_KEY_Down,       focusdir,         {.ui = 3} },

        { MODKEY,       XKB_KEY_Return,     zoom,             {0} },
        { MODKEY|SHIFT, XKB_KEY_Return,     togglenmaster,    {0} },

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
        { MODKEY,       XKB_KEY_w,          spawn,            ${cCmd [ (lib.getExe wallpaper-selector) ]} },
        { MODKEY|SHIFT, XKB_KEY_w,          spawn,            ${cCmd [ (lib.getExe wallpaper) ]} },

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

        { CTRL|ALT, XKB_KEY_Terminate_Server, spawn, ${cCmd [ "sh" "-c" logoutCmd ]} },

    #define CHVT(n) { CTRL|ALT, XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
        CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
        CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
    };

    static const Button buttons[] = {
        { MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
        { MODKEY, BTN_MIDDLE, togglefloating, {0} },
        { MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
        { MODKEY|SHIFT, BTN_MIDDLE, moveresize, {.ui = Curmfact} },
    };
  '';

  fcitx5 = config.i18n.inputMethod.package;

  guardX = bin: cmd: "${pkgs.procps}/bin/pgrep -x ${bin} >/dev/null || ${cmd} &";
  guardF = pattern: cmd: "${pkgs.procps}/bin/pgrep -f '${pattern}' >/dev/null || ${cmd} &";

  startup = pkgs.writeShellScript "dwl-startup" (
    lib.concatStringsSep "\n" [
      "exec >>\"\${XDG_RUNTIME_DIR:-/tmp}/dwl-startup.log\" 2>&1"
      "set -x"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
      "systemctl --user start graphical-session.target"

      (guardX "dwlb" "${lib.getExe pkgs.dwlb} -font \"monospace,Symbols Nerd Font Mono:size=11\" -ipc -custom-title -hide-vacant-tags -vertical-padding 0 -active-fg-color \"#${base16.base00}\" -active-bg-color \"#${base16.base0C}\" -occupied-fg-color \"#${base16.base05}\" -occupied-bg-color \"#${base16.base02}\" -inactive-fg-color \"#${base16.base04}\" -inactive-bg-color \"#${base16.base01}\" -urgent-fg-color \"#${base16.base00}\" -urgent-bg-color \"#${base16.base08}\" -middle-bg-color \"#${base16.base00}\" -middle-bg-color-selected \"#${base16.base01}\"")

      "sleep 1"

      (guardX "mako" (lib.getExe pkgs.mako))
      (guardF "dwl-wallpaper-daemon" (lib.getExe wallpaperDaemon))
      (guardX "dwl-status" (lib.getExe dwlStatus))

      "cliphist wipe &"
      (guardX "keepassxc" "${lib.getExe pkgs.keepassxc} --minimized")
      (guardF "${lib.getExe pkgs.lf} -server" "${lib.getExe pkgs.lf} -server")
      (guardX "fcitx5" (lib.getExe' fcitx5 "fcitx5"))
      (guardX "wl-clip-persist" "${lib.getExe' pkgs.wl-clip-persist "wl-clip-persist"} --clipboard regular")
      (guardX "polkit-mate-authentication-agent" "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1")
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
        ./btrtile-smartgaps.patch
        ./alwayscenter.patch
        ./focusdir.patch
        ./swallow.patch
      ]
      ++ lib.optionals effects [
        ./scenefx.patch
        ./smartcorners.patch
      ]
      ++ [
        ./smartborders.patch
        ./togglenmaster.patch
        ./dragmfact.patch
      ];
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
      systemctl --user stop graphical-session.target
    else
      exec /etc/xdg/dwl-session
    fi
  '';

  environment.loginShellInit = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      for f in /etc/profile.d/*.sh; do
        . "$f"
      done

      # home-manager's session variables (e.g. BEMENU_OPTS) live in
      # ~/.profile, which normal login shells source after /etc/profile.
      # We exec away below before bash gets to do that, so source it
      # ourselves.
      [ -r "$HOME/.profile" ] && . "$HOME/.profile"

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
