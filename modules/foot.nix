{
  config,
  lib,
  ...
}:
{
  home.sessionVariables.TERMINAL = "foot";
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = config.shell;
        dpi-aware = lib.mkForce "yes";
        pad = "16x16";
        resize-by-cells = false;
        resize-keep-grid = false;
        font = lib.mkForce "${config.stylix.fonts.monospace.name}:size=${toString config.stylix.fonts.sizes.terminal},Symbols Nerd Font Mono:size=${toString config.stylix.fonts.sizes.terminal}";
      };
    };
  };
}
