{
  pkgs,
  lib,
  base16,
  flakeDir,
  term,
  home,
  documents,
  editor,
  umountPersonal,
}:
rec {
  shell = "${pkgs.busybox}/bin/sh";

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
    "${lib.getExe pkgs.yq-go} -r '.[]' /run/secrets/bookmarks | ${lib.getExe bemenuPatched} -i -p bookmarks | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
  ];

  clipboard = [
    shell
    "-c"
    "${lib.getExe pkgs.cliphist} list | ${lib.getExe bemenuPatched} | ${lib.getExe pkgs.cliphist} decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
  ];

  kaomojiRepo = pkgs.fetchFromGitHub {
    owner = "jim-ww";
    repo = "kaomoji-csv";
    rev = "9c7d5bbcc968cb9f2d077ed8dfeeabbd0b3b4c1a";
    hash = "sha256-TnFvZWURAjUbtz8YBoaLsNYHLinC+urR/N2xPyJbLLM=";
  };

  kaomojiData = "${kaomojiRepo}/kaomoji.csv";

  kaomoji = pkgs.writeShellScriptBin "kaomoji" ''
    ${lib.getExe bemenuPatched} -i -p kaomoji --width-factor 0.4 < ${kaomojiData} |
      awk '{print $1}' |
      sed 's/\\xc2\\xa0/ /g' |
      ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
  '';

  notes = [
    term
    "sh"
    "-c"
    "cd ${documents} && exec ${editor} TODO.md"
  ];

  notesAll = [
    term
    "sh"
    "-c"
    "cd ${documents} && exec ${editor} ."
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
        kind="gui"
        [ "$(grep -m1 '^Terminal=' "$f" | cut -d= -f2-)" = "true" ] && kind="term"
        [ -n "$name" ] && [ -n "$exec_cmd" ] && printf '%s|%s|%s\n' "$name" "$exec_cmd" "$kind"
      done

      compgen -c 2>/dev/null | sort -u | while read -r cmd; do
        [ -n "$cmd" ] && printf '%s|%s|%s\n' "$cmd" "$cmd" "term"
      done
    } > "$tmp"

    choice=$(cut -d'|' -f1 "$tmp" | ${lib.getExe bemenuPatched} -i -p run --list 15)
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
    "choice=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '[0-9]+\\.' | ${lib.getExe bemenuPatched} -p output)"
  ];

  screenlock = [
    shell
    "-c"
    "${lib.getExe pkgs.swaylock} -efkli ${flakeDir}/wallpaper && ${umountPersonal}"
  ];

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

    # swaybg's nix wrapper execs into a binary named ".swaybg-wrapped", so
    # its kernel comm is never "swaybg" -- pkill -x swaybg silently never
    # matched it. drop -x so it's a substring match instead, which still
    # catches ".swaybg-wrapped".
    ${pkgs.procps}/bin/pkill swaybg 2>/dev/null

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
      local full state_line song state symbol text=""
      full=$(${lib.getExe pkgs.mpc} -f '[%artist% - %title%]|[FILE:%file%]' status 2>/dev/null)
      # mpc only prints the song line when a track is actually loaded, so
      # the [state] line isn't always on a fixed line number -- find it
      # instead of assuming line 2 (otherwise, e.g. mid next/prev with no
      # current track, we'd grab the volume/repeat/random line as "song").
      state_line=$(printf '%s\n' "$full" | grep -n '^\[[a-z]*\]' | head -n1 | cut -d: -f1)
      if [ -n "$state_line" ]; then
        song=$(printf '%s\n' "$full" | sed -n "$((state_line - 1))p")
      else
        song=""
      fi
      case "$song" in
        FILE:*) song="''${song#FILE:}"; song="''${song##*/}"; song="''${song%.*}" ;;
      esac
      if [ -n "$song" ]; then
        state=$(printf '%s\n' "$full" | sed -n "''${state_line}{s/.*\[\([a-z]*\)\].*/\1/p}")
        case "$state" in
          playing) symbol=$'\uf04b' ;;
          paused) symbol=$'\uf04c' ;;
          *) symbol=$'\uf04d' ;;
        esac
        [ "''${#song}" -gt 40 ] && song="''${song:0:39}…"
        text="^lm(${lib.getExe pkgs.mpc} toggle)^mm(${lib.getExe pkgs.mpc} prev)^rm(${lib.getExe pkgs.mpc} next)$symbol $song^rm()^mm()^lm()"
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
          if [ "$status" = "Charging" ] && [ "''${capacity:-100}" -lt 100 ]; then
            text=" $text"
          fi
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
    history=""
    while true; do
      expr=$(printf '%s' "$history" | ${lib.getExe bemenuPatched} -p "calc:")
      [ -n "$expr" ] || exit 0

      if ! result=$(printf '%s\n' "$expr" | ${lib.getExe pkgs.bc} -lq 2>&1); then
        history="$expr = error: $result
$history"
        continue
      fi
      [ -n "$result" ] || continue

      printf '%s' "$result" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
      history="$expr = $result
$history"
    done
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
