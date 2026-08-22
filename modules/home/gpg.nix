{
  pkgs,
  config,
  ...
}:
{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableBashIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 1800;
    defaultCacheTtlSsh = 1800;
  };

  home.packages = [ pkgs.gcr ]; # for gnome-pinentry
}
