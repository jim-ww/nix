{
  pkgs,
  lib,
  base16,
  flakeDir,
  term,
}:
rec {
  # plain left/right move the text cursor upstream; remap them to page
  # up/down (shift+left/right jumps to top/bottom), same override as
  # ./bemenu.nix's programs.bemenu.package.
  bemenuPatched = pkgs.bemenu.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./bemenu-leftright-page.patch ];
  });

  # upstream only wires scroll-to-command up to the deprecated
  # wl_pointer.axis_discrete event; most current compositors send
  # axis_value120 instead, so status-bar scroll actions never fire.
  dwlbPatched = pkgs.dwlb.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./dwlb-scroll-value120.patch ];
  });

  wallpaperApply = pkgs.writeShellScriptBin "wl-wallpaper-apply" ''
    [ -n "$1" ] && [ -f "$1" ] || exit 0

    # the keybinds and the autostart daemon can all call this independently;
    # without a lock, two concurrent kill+spawn cycles can interleave and
    # leave more than one swaybg alive.
    lock="''${XDG_RUNTIME_DIR:-/tmp}/wl-wallpaper.lock"
    exec 9>"$lock"
    ${lib.getExe' pkgs.util-linux "flock"} -x 9

    ${pkgs.procps}/bin/pkill -x swaybg
    for _ in $(seq 1 40); do
      ${pkgs.procps}/bin/pgrep -x swaybg >/dev/null || break
      sleep 0.05
    done
    ${pkgs.procps}/bin/pkill -9 -x swaybg 2>/dev/null

    # close the lock fd in the child so swaybg (which outlives this script)
    # doesn't hold the flock open forever and deadlock the next invocation.
    ${lib.getExe pkgs.swaybg} -i "$1" -m fill 9>&- &
    disown
  '';

  wallpaperSet = pkgs.writeShellScriptBin "wl-wallpaper-set" ''
    dir="${flakeDir}/wallpapers"
    fallback="${flakeDir}/wallpaper"

    pick="$fallback"
    if [ -d "$dir" ]; then
      mapfile -t files < <(find "$dir" -maxdepth 1 -type f)
      if [ "''${#files[@]}" -gt 0 ]; then
        pick="''${files[$RANDOM % ''${#files[@]}]}"
      fi
    fi

    exec ${lib.getExe wallpaperApply} "$pick"
  '';

  wallpaper = pkgs.writeShellScriptBin "wl-wallpaper" ''
    exec ${lib.getExe wallpaperSet}
  '';

  wallpaperDaemon = pkgs.writeShellScriptBin "wl-wallpaper-daemon" ''
    lock="''${XDG_RUNTIME_DIR:-/tmp}/wl-wallpaper-daemon.lock"
    exec 9>"$lock"
    ${lib.getExe' pkgs.util-linux "flock"} -n 9 || exit 0

    while true; do
      ${lib.getExe wallpaperSet}
      sleep 1800
    done
  '';

  wallpaperSelector = pkgs.writeShellScriptBin "wl-wallpaper-selector" ''
    dir="${flakeDir}/wallpapers"
    [ -d "$dir" ] || exit 0

    shopt -s nullglob
    files=("$dir"/*)
    [ "''${#files[@]}" -gt 0 ] || exit 0

    # this session never runs xrdb, so XWayland clients (nsxiv included)
    # never see our ~/.Xresources colors without this.
    [ -r "$HOME/.Xresources" ] && ${lib.getExe pkgs.xrdb} -merge "$HOME/.Xresources"

    pick=$(${lib.getExe pkgs.nsxiv} -to "''${files[@]}" 2>/dev/null | head -n1)
    [ -n "$pick" ] || exit 0

    exec ${lib.getExe wallpaperApply} "$pick"
  '';

  status = pkgs.writeShellScriptBin "wl-status" ''
    set -u

    lock="''${XDG_RUNTIME_DIR:-/tmp}/wl-status.lock"
    exec 4>"$lock"
    ${lib.getExe' pkgs.util-linux "flock"} -n 4 || exit 0

    fifo="''${XDG_RUNTIME_DIR:-/tmp}/wl-status.fifo"
    rm -f "$fifo"
    mkfifo "$fifo"
    exec 3<>"$fifo"

    order=(mpd audio time battery)
    declare -A blocks=()

    render() {
      # dwlb draws status text with inactive-fg-color by default, which
      # in our theme is a dim shade meant for unfocused tags; force the
      # brighter default foreground instead.
      local out="^fg(${base16.base05})" sep=""
      for name in "''${order[@]}"; do
        local text="''${blocks[$name]:-}"
        [ -n "$text" ] || continue
        out+="''${sep}''${text}"
        sep=" ^fg(${base16.base03})|^fg() "
      done
      ${lib.getExe dwlbPatched} -status all "$out"
    }

    update_mpd() {
      local full song state symbol text=""
      full=$(${lib.getExe pkgs.mpc} -f '[%artist% - %title%]|[FILE:%file%]' status 2>/dev/null)
      song=$(printf '%s\n' "$full" | sed -n '1p')
      case "$song" in
        FILE:*) song="''${song#FILE:}"; song="''${song##*/}"; song="''${song%.*}" ;;
      esac
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
        text="^lm(${lib.getExe pkgs.pamixer} -t)^rm(${term} -e ${lib.getExe pkgs.pulsemixer})^us(${lib.getExe pkgs.pamixer} -i 5)^ds(${lib.getExe pkgs.pamixer} -d 5)$icon $label^ds()^us()^rm()^lm()"
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
      printf 'time\t%s %s\n' "$icon" "$(${lib.getExe' pkgs.coreutils "date"} '+%a %d %b %H:%M')" >&3
    }

    time_loop() {
      while true; do
        update_time
        sleep 15
      done
    }

    update_battery() {
      local bat status capacity text="" icon
      bat=$(${lib.getExe' pkgs.findutils "find"} /sys/class/power_supply -maxdepth 1 -name 'BAT*' 2>/dev/null | head -n1)
      if [ -n "$bat" ]; then
        status=$(${lib.getExe' pkgs.coreutils "cat"} "$bat/status" 2>/dev/null)
        capacity=$(${lib.getExe' pkgs.coreutils "cat"} "$bat/capacity" 2>/dev/null)
        if [ "''${capacity:-100}" -ge 80 ]; then
          icon=$'\uf240'
        elif [ "''${capacity:-100}" -ge 60 ]; then
          icon=$'\uf241'
        elif [ "''${capacity:-100}" -ge 40 ]; then
          icon=$'\uf242'
        elif [ "''${capacity:-100}" -ge 20 ]; then
          icon=$'\uf243'
        else
          icon=$'\uf244'
        fi
        # show whenever not sitting fully-charged on the charger
        if [ "$status" != "Charging" ] && [ "$status" != "Full" ] || [ "''${capacity:-100}" -lt 100 ]; then
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

  calculator = pkgs.writeShellScriptBin "wl-calculator" ''
    expr=$(${lib.getExe bemenuPatched} -p "calc:" < /dev/null)
    [ -n "$expr" ] || exit 0

    if ! result=$(printf '%s\n' "$expr" | ${lib.getExe pkgs.bc} -lq 2>&1); then
      printf '%s\n' "$result" | ${lib.getExe bemenuPatched} -p "calc failed:" > /dev/null
      exit 1
    fi
    [ -n "$result" ] || exit 0

    printf '%s' "$result" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
    printf '%s\n' "$expr = $result" | ${lib.getExe bemenuPatched} -p "calc:" > /dev/null
  '';

  translator = pkgs.writeShellScriptBin "wl-translate" ''
    text=$(${lib.getExe bemenuPatched} -p "translate:" < /dev/null)
    [ -n "$text" ] || exit 0

    if ! result=$(gtr "$text" 2>&1); then
      printf '%s\n' "$result" | ${lib.getExe bemenuPatched} -p "translate failed:" > /dev/null
      exit 1
    fi

    printf '%s' "$result" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
    printf '%s\n' "$result" | ${lib.getExe bemenuPatched} -p "translate:" > /dev/null
  '';
}
