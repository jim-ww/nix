{
  pkgs,
  config,
  ...
}:
let
  baseArgs = [
    "--ro-bind"
    "/usr"
    "/usr"
    "--ro-bind"
    "/nix"
    "/nix"
    "--ro-bind"
    "/etc"
    "/etc"
    "--ro-bind"
    "/run/current-system"
    "/run/current-system"
    "--ro-bind"
    "/run/systemd/resolve"
    "/run/systemd/resolve"
    "--symlink"
    "/usr/lib"
    "/lib"
    "--symlink"
    "/usr/lib64"
    "/lib64"
    "--symlink"
    "/usr/bin"
    "/bin"
    "--symlink"
    "/usr/sbin"
    "/sbin"
    "--proc"
    "/proc"
    "--dev"
    "/dev"
    "--tmpfs"
    "/tmp"
    "--unshare-all"
    "--unshare-user"
    "--disable-userns"
    "--die-with-parent"
    "--cap-drop"
    "ALL"
    "--hostname"
    "sandbox"
    "--clearenv"
    "--setenv"
    "PATH"
    "${pkgs.git}/bin:/etc/profiles/per-user/${config.user}/bin:/run/current-system/sw/bin:/usr/bin:/usr/sbin"
    "--setenv"
    "HOME"
    "$HOME"
    "--setenv"
    "USER"
    "$USER"
    "--setenv"
    "TERM"
    "$TERM"
    "--setenv"
    "LANG"
    "$LANG"
    "--setenv"
    "XDG_CACHE_HOME"
    "$HOME/.cache"
  ];

  homeBinds = [
    ''--bind "$HOME/.cache/sandbox" "$HOME"''
    ''--bind "/persistent$HOME/.claude" "$HOME/.claude"''
    ''--bind "/persistent$HOME/.claude.json" "$HOME/.claude.json"''
    ''--bind "/persistent$HOME/.cache" "$HOME/.cache"''
    ''--bind "/persistent$HOME/.local/share/itpec-sensei" "$HOME/.local/share/itpec-sensei"''
    ''--dir "$HOME/.local/share/gnupg"''
    ''--ro-bind-try "$HOME/.bashrc" "$HOME/.bashrc"''
    ''--ro-bind-try "$HOME/.profile" "$HOME/.profile"''
    ''--ro-bind-try "$HOME/.bash_profile" "$HOME/.bash_profile"''
  ];

  guiPreamble = ''
    RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    WAYLAND_SOCK="$RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-1}"
    DBUS_PROXY_SOCKET="$RUNTIME_DIR/bwrap-dbus-$$"

    ${pkgs.xdg-dbus-proxy}/bin/xdg-dbus-proxy \
      "$DBUS_SESSION_BUS_ADDRESS" "$DBUS_PROXY_SOCKET" \
      --filter \
      --talk=org.freedesktop.Notifications \
      --talk=org.freedesktop.portal.Desktop &
    DBUS_PROXY_PID=$!
    trap 'kill "$DBUS_PROXY_PID" 2>/dev/null; rm -f "$DBUS_PROXY_SOCKET"' EXIT
    for _ in $(seq 1 50); do [ -S "$DBUS_PROXY_SOCKET" ] && break; sleep 0.1; done

    GUI_ARGS=(
      --dir "$RUNTIME_DIR"
      --bind "$DBUS_PROXY_SOCKET" "$RUNTIME_DIR/bus"
      --setenv DBUS_SESSION_BUS_ADDRESS "unix:path=$RUNTIME_DIR/bus"
      --setenv XDG_RUNTIME_DIR "$RUNTIME_DIR"
    )
    if [ -S "$WAYLAND_SOCK" ]; then
      GUI_ARGS+=(--ro-bind "$WAYLAND_SOCK" "$WAYLAND_SOCK" --setenv WAYLAND_DISPLAY "''${WAYLAND_DISPLAY:-wayland-1}")
    fi
    if [ -d /tmp/.X11-unix ]; then
      GUI_ARGS+=(--ro-bind /tmp/.X11-unix /tmp/.X11-unix --setenv DISPLAY "''${DISPLAY:-:0}")
    fi
    if [ -n "$XAUTHORITY" ] && [ -f "$XAUTHORITY" ]; then
      GUI_ARGS+=(--ro-bind "$XAUTHORITY" "$XAUTHORITY" --setenv XAUTHORITY "$XAUTHORITY")
    fi
  '';

  mkBwrap =
    {
      name,
      net,
      cwdBind,
    }:
    let
      args = baseArgs ++ (if net then [ "--share-net" ] else [ ]);
      argsStr = builtins.concatStringsSep " " (map (a: "\"${a}\"") args);
      bindsStr = builtins.concatStringsSep " \\\n      " homeBinds;
    in
    if cwdBind then
      pkgs.writeShellScriptBin name ''
        mkdir -p "$HOME/.cache/sandbox"
        case "$PWD" in
          "$HOME"/*) CWDPATH="''${PWD#$HOME/}" ;;
          /*) CWDPATH="''${PWD#/}" ;;
          *) CWDPATH="$PWD" ;;
        esac
        SANDBOX_BASE="$HOME/.cache/sandbox"
        TARGET="$SANDBOX_BASE/$CWDPATH"
        mkdir -p "$TARGET"
        exec {CWD_LOCKFD}<"$TARGET"
        ${pkgs.util-linux}/bin/flock -s "$CWD_LOCKFD"
        ${guiPreamble}
        ${pkgs.bubblewrap}/bin/bwrap \
          ${argsStr} \
          ${bindsStr} \
          "''${GUI_ARGS[@]}" \
          --bind "$PWD" "$HOME/$CWDPATH" \
          --chdir "$HOME/$CWDPATH" \
          -- \
          "''${@:-bash}"
        STATUS=$?
        if ${pkgs.util-linux}/bin/flock -xn "$CWD_LOCKFD"; then
          d="$TARGET"
          while [ "$d" != "$SANDBOX_BASE" ]; do
            rmdir "$d" 2>/dev/null || break
            d="$(dirname "$d")"
          done
        fi
        exit "$STATUS"
      ''
    else
      pkgs.writeShellScriptBin name ''
        mkdir -p "$HOME/.cache/sandbox"
        ${guiPreamble}
        exec ${pkgs.bubblewrap}/bin/bwrap \
          ${argsStr} \
          ${bindsStr} \
          "''${GUI_ARGS[@]}" \
          --chdir "$HOME" \
          -- \
          "''${@:-bash}"
      '';

  # Ephemeral-home sandbox: $HOME is disk-backed under ~/.cache/sandbox, no
  # access to real files anywhere else.
  bwrap = mkBwrap {
    name = "bwrap";
    net = true;
    cwdBind = false;
  };

  # Same sandbox home, plus the real $PWD rw-bound as a same-named dir,
  # and that's where the sandbox starts.
  bwrapCwd = mkBwrap {
    name = "bwrap-cwd";
    net = true;
    cwdBind = true;
  };

  bwrapCwdOffline = mkBwrap {
    name = "bwrap-cwd-offline";
    net = false;
    cwdBind = true;
  };
in
{
  home.packages = [
    bwrap
    bwrapCwd
    bwrapCwdOffline
  ];
}
