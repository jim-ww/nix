{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true; # only for flatpak/sandboxed apps, or not. drag&drop stops working without it, and some xdg home-manager mime types too
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
  # fix urls not openning
  # systemd.user.settings.Manager = {
  #   DefaultEnvironment = "PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  # };
}
