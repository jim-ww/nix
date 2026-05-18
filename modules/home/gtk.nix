{
  pkgs,
  config,
  ...
}:
let
  gtk3Bookmarks = config.gtk.bookmarks;
in
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Paper"; # "Adwaita";
      package = pkgs.paper-icon-theme; # pkgs.adwaita-icon-theme;
    };
    gtk3.bookmarks = gtk3Bookmarks;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}
