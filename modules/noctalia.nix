{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  bookmarks = osConfig.sops.secrets.bookmarks.path;
  wallhavenKey = osConfig.sops.secrets.wallhaven-api-key.path;
  target = "${config.xdg.configHome}/noctalia/config.toml";
  state = "${config.xdg.stateHome}/noctalia/settings.toml";
  importScript = pkgs.writeShellScript "noctalia-import" ''
    set -euo pipefail
    dst=${osConfig.flakeDir}/modules/noctalia.toml
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT
    ${lib.getExe config.programs.noctalia.package} config export | ${pkgs.gawk}/bin/awk '
      /^[[:space:]]*\[\[?[A-Za-z_]/ { sec = $0; gsub(/^[[:space:]]+|[[:space:]]+$/, "", sec) }
      sec == "[plugin_settings.\"yocraft/web-launcher\"]" { next }
      sec == "[plugin_settings.\"noctalia/wallhaven\"]" && /^[[:space:]]*api_key[[:space:]]*=/ { next }
      { print }
    ' > "$tmp"
    if ${lib.getExe pkgs.gnugrep} -qF -f <({ cat ${wallhavenKey}; echo; ${lib.getExe pkgs.yq-go} '.[]' ${bookmarks}; } | ${lib.getExe pkgs.gnugrep} -v '^[[:space:]]*$') "$tmp"; then
      echo "noctalia-import: secret value still present, aborting" >&2
      exit 1
    fi
    cat "$tmp" > "$dst"
  '';
in
{
  home.packages = with pkgs; [
    udiskie
  ];

  home.shellAliases.noctalia-import = "${importScript}";

  stylix.targets.noctalia.enable = false;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  home.activation.noctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname ${target})"
    rm -f ${target}
    if [ -r ${bookmarks} ] && [ -r ${wallhavenKey} ]; then
      ${lib.getExe pkgs.yq-go} -p toml -o toml \
        '.plugin_settings."yocraft/web-launcher" = {"links": (load("${bookmarks}") | map((. | sub("^[a-z]+://(www\\.)?"; "") | sub("[/:?#].*$"; "")) + "|" + .))}
        | .plugin_settings."noctalia/wallhaven".api_key = (load_str("${wallhavenKey}") | trim)' \
        ${./noctalia.toml} > ${target}
    else
      install -m 0644 ${./noctalia.toml} ${target}
    fi
    if [ -f ${state} ]; then
      ${lib.getExe pkgs.yq-go} -i -p toml -o toml \
        'del(.plugin_settings."yocraft/web-launcher") | del(.plugin_settings."noctalia/wallhaven".api_key)' \
        ${state}
    fi
  '';
}
