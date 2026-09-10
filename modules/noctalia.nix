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
in
{
  home.packages = with pkgs; [
    udiskie
  ];

  stylix.targets.noctalia.enable = false;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  home.activation.noctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname ${target})"
    rm -f ${target}
    ${lib.getExe pkgs.yq-go} -p toml -o toml \
      '.plugin_settings."yocraft/web-launcher" = {"links": (load("${bookmarks}") | map((. | sub("^[a-z]+://(www\\.)?"; "") | sub("[/:?#].*$"; "")) + "|" + .))}
      | .plugin_settings."noctalia/wallhaven".api_key = (load_str("${wallhavenKey}") | trim)' \
      ${./noctalia.toml} > ${target}
    if [ -f ${state} ]; then
      ${lib.getExe pkgs.yq-go} -i -p toml -o toml \
        'del(.plugin_settings."yocraft/web-launcher") | del(.plugin_settings."noctalia/wallhaven".api_key)' \
        ${state}
    fi
  '';
}
