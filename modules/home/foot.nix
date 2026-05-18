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
      };
    };
  };
}
