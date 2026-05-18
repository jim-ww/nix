{
  pkgs,
  config,
  ...
}:
let
  mimeApps = config.mimeApps;
in
{
  xdg.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = mimeApps;
  xdg.mimeApps.associations.added = mimeApps;

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    publicShare = "${config.home.homeDirectory}/Downloads";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common = {
      default = [
        "wlr"
        "gtk"
      ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
}
