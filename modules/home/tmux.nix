{
  pkgs,
  lib,
  ...
}:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shell = lib.getExe pkgs.fish;
    extraConfig = ''
      set -g mouse on
    '';
  };
}
