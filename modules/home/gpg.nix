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
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 1800;
    defaultCacheTtlSsh = 1800;
  };
}
