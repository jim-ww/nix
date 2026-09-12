{
  pkgs,
  config,
  lib,
  ...
}:
let
  home = "/home/${config.user}";
  documents = "${home}/Documents";

  effects = true;

  # "btrtile" (splits the focused window toward the pointer), "tile"
  # (master-stack), "monocle" or "floating"
  layout = "btrtile";

  layoutIndex =
    {
      tile = 0;
      floating = 1;
      monocle = 2;
      btrtile = 3;
    }
    .${layout};

  ipc = ''"noctalia", "msg"'';
  term = ''"xdg-terminal-exec", "--"'';

  configH = ''
    #define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                            ((hex >> 16) & 0xFF) / 255.0f, \
                            ((hex >> 8) & 0xFF) / 255.0f, \
                            (hex & 0xFF) / 255.0f }

    static const int sloppyfocus               = 1;
    static const int bypass_surface_visibility = 0;
    static const unsigned int borderpx         = 1;
    static const unsigned int gappx            = 4;
    static int gaps                            = 1;
    static const int smartgaps                 = 1;
    static const float resize_factor           = 0.0002f;
    static const uint32_t resize_interval_ms   = 16;

    enum Direction { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN };
    static const float rootcolor[]             = COLOR(0x222222ff);
    static const float bordercolor[]           = COLOR(0x444444ff);
    static const float focuscolor[]            = COLOR(0x005577ff);
    static const float urgentcolor[]           = COLOR(0xff0000ff);
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
        { MODKEY|SHIFT, XKB_KEY_m,          quit,             {0} },
        { MODKEY,       XKB_KEY_v,          togglefloating,   {0} },
        { MODKEY|SHIFT, XKB_KEY_f,          togglefullscreen, {0} },

        { MODKEY,       XKB_KEY_Up,         focusstack,       {.i = -1} },
        { MODKEY,       XKB_KEY_Down,       focusstack,       {.i = +1} },
        { MODKEY,       XKB_KEY_Left,       focusstack,       {.i = -1} },
        { MODKEY,       XKB_KEY_Right,      focusstack,       {.i = +1} },
        { ALT,          XKB_KEY_Tab,        spawn,            CMD(${ipc}, "window-switcher") },

        { MODKEY,       XKB_KEY_g,          setlayout,        {.v = &layouts[0]} },
        { MODKEY,       XKB_KEY_n,          setlayout,        {.v = &layouts[3]} },

        { MODKEY|SHIFT, XKB_KEY_Up,         swapclients,      {.i = DIR_UP} },
        { MODKEY|SHIFT, XKB_KEY_Down,       swapclients,      {.i = DIR_DOWN} },
        { MODKEY|SHIFT, XKB_KEY_Left,       swapclients,      {.i = DIR_LEFT} },
        { MODKEY|SHIFT, XKB_KEY_Right,      swapclients,      {.i = DIR_RIGHT} },

        { MODKEY|CTRL,  XKB_KEY_Left,       setratio_h,       {.f = -0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Right,      setratio_h,       {.f = +0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Up,         setratio_v,       {.f = -0.025f} },
        { MODKEY|CTRL,  XKB_KEY_Down,       setratio_v,       {.f = +0.025f} },

        { MODKEY,       XKB_KEY_q,          spawn,            CMD("footclient") },
        { MODKEY|SHIFT, XKB_KEY_q,          spawn,            CMD("foot") },
        { MODKEY,       XKB_KEY_t,          spawn,            CMD("footclient", "--title=term-float") },
        { MODKEY|SHIFT, XKB_KEY_t,          spawn,            CMD(${ipc}, "panel-toggle", "launcher", "/tr ") },
        { MODKEY,       XKB_KEY_e,          spawn,            CMD(${term}, "${lib.getExe pkgs.lf}") },
        { MODKEY,       XKB_KEY_f,          spawn,            CMD("${config.browser}") },
        { MODKEY,       XKB_KEY_s,          spawn,            CMD(${term}, "rmpc", "--clean") },
        { MODKEY|SHIFT, XKB_KEY_s,          spawn,            CMD(${ipc}, "panel-toggle", "reaperhound/ambient-sounds:main") },
        { MODKEY|SHIFT, XKB_KEY_a,          spawn,            CMD(${ipc}, "panel-toggle", "control-center", "system") },
        { MODKEY,       XKB_KEY_w,          spawn,            CMD(${ipc}, "panel-toggle", "wallpaper") },
        { MODKEY|SHIFT, XKB_KEY_w,          spawn,            CMD(${ipc}, "panel-toggle", "noctalia/wallhaven:browser") },
        { MODKEY,       XKB_KEY_b,          spawn,            CMD("keepassxc", "${documents}/.vault.kdbx") },
        { MODKEY,       XKB_KEY_k,          spawn,            CMD(${ipc}, "panel-toggle", "launcher", "/calc ") },
        { MODKEY|SHIFT, XKB_KEY_b,          spawn,            CMD(${ipc}, "panel-toggle", "launcher", "/web ") },
        { MODKEY,       XKB_KEY_j,          spawn,            CMD(${ipc}, "panel-toggle", "launcher", "/kao ") },
        { MODKEY,       XKB_KEY_x,          spawn,            CMD(${term}, "sh", "-c", "cd \"${documents}\" && exec ${config.editor} TODO.md") },
        { MODKEY|SHIFT, XKB_KEY_x,          spawn,            CMD(${term}, "sh", "-c", "cd \"${documents}\" && exec ${config.editor} .") },
        { MODKEY,       XKB_KEY_d,          spawn,            CMD(${term}, "${config.editor}") },
        { MODKEY,       XKB_KEY_z,          spawn,            CMD(${term}, "kage") },
        { MODKEY,       XKB_KEY_Tab,        spawn,            CMD(${ipc}, "panel-toggle", "control-center") },
        { MODKEY,       XKB_KEY_p,          spawn,            CMD(${ipc}, "panel-toggle", "control-center", "audio") },
        { MODKEY,       XKB_KEY_r,          spawn,            CMD(${ipc}, "panel-toggle", "launcher") },
        { MODKEY,       XKB_KEY_l,          spawn,            CMD(${ipc}, "session", "lock") },
        { MODKEY|SHIFT, XKB_KEY_c,          spawn,            CMD(${ipc}, "panel-toggle", "clipboard") },
        { 0,            XKB_KEY_Print,      spawn,            CMD(${ipc}, "screenshot-region") },
        { MODKEY,       XKB_KEY_Print,      spawn,            CMD(${ipc}, "screenshot-fullscreen") },

        { MODKEY,       XKB_KEY_F1,         spawn,            CMD(${ipc}, "dpms-on") },
        { MODKEY,       XKB_KEY_F2,         spawn,            CMD(${ipc}, "dpms-off") },

        { LOCKED, XKB_KEY_XF86AudioRaiseVolume,  spawn,            CMD(${ipc}, "volume-up") },
        { LOCKED, XKB_KEY_XF86AudioLowerVolume,  spawn,            CMD(${ipc}, "volume-down") },
        { LOCKED, XKB_KEY_XF86AudioMute,         spawn,            CMD(${ipc}, "volume-mute") },

        { LOCKED, XKB_KEY_XF86AudioPlay,         spawn,            CMD("playerctl", "-p", "mpd", "play-pause") },
        { LOCKED, XKB_KEY_XF86AudioPause,        spawn,            CMD("playerctl", "-p", "mpd", "pause") },
        { LOCKED, XKB_KEY_XF86AudioNext,         spawn,            CMD("playerctl", "-p", "mpd", "next") },
        { LOCKED, XKB_KEY_XF86AudioPrev,         spawn,            CMD("playerctl", "-p", "mpd", "previous") },

        { LOCKED, XKB_KEY_XF86MonBrightnessUp,   spawn,            CMD(${ipc}, "brightness-up", "10") },
        { LOCKED, XKB_KEY_XF86MonBrightnessDown, spawn,            CMD(${ipc}, "brightness-down", "10") },

        TAGKEYS( XKB_KEY_1, 0),
        TAGKEYS( XKB_KEY_2, 1),
        TAGKEYS( XKB_KEY_3, 2),
        TAGKEYS( XKB_KEY_4, 3),
        TAGKEYS( XKB_KEY_5, 4),
        TAGKEYS( XKB_KEY_6, 5),
        TAGKEYS( XKB_KEY_7, 6),
        TAGKEYS( XKB_KEY_8, 7),
        TAGKEYS( XKB_KEY_9, 8),
        TAGKEYS( XKB_KEY_0, 9),

        { CTRL|ALT, XKB_KEY_Terminate_Server, quit, {0} },
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
  kage = lib.findFirst (
    p: (p.pname or p.name or "") == "kage"
  ) (throw "dwl: kage not found in config.packages") config.packages;

  fcitx5 = config.i18n.inputMethod.package;

  startup = pkgs.writeShellScript "dwl-startup" (
    lib.concatStringsSep "\n" [
      "exec >>\"\${XDG_RUNTIME_DIR:-/tmp}/dwl-startup.log\" 2>&1"
      "set -x"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
      "systemctl --user start dwl-session.target"
      "${lib.getExe' kage "kage"} daemon start &"
      "${lib.getExe pkgs.keepassxc} --minimized &"
      "${lib.getExe pkgs.lf} -server &"
      "${lib.getExe' fcitx5 "fcitx5"} &"
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
      ]
      ++ lib.optional effects ./scenefx.patch;
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
        wrapProgram $out/bin/dwl --add-flags "-s ${startup}"
      '';
      meta.mainProgram = "dwl";
    };
    extraSessionCommands = lib.concatStringsSep "\n" [
      "export XDG_CURRENT_DESKTOP=dwl"
      "export XDG_SESSION_TYPE=wayland"
    ];
  };

  services.speechd.enable = false;

  environment.etc."xdg/dwl-session".text = lib.mkForce ''
    #!${pkgs.runtimeShell}
    ${config.programs.dwl.extraSessionCommands}
    ${lib.getExe config.programs.dwl.package} 2>>"''${XDG_RUNTIME_DIR:-/tmp}/dwl.log"
    systemctl --user stop dwl-session.target
  '';

  environment.loginShellInit = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      for f in /etc/profile.d/*.sh; do . "$f"; done
      exec /etc/xdg/dwl-session
    fi
  '';

  hm =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        xdg-utils
        wl-clipboard
        wf-recorder
        libnotify
        playerctl
      ];

      services.hyprpaper.enable = lib.mkForce false;
    };
}
