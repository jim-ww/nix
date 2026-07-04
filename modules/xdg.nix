{pkgs, ...}: {
  # fix urls not openning
  systemd.user.settings.Manager = {
    DefaultEnvironment = "PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = [
      "wlr"
      "gtk"
    ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["foot.desktop"];
  };
}
