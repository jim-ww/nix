{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings.default = [ "foot.desktop" ];
}
