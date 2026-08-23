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
    pinentry.package = pkgs.pinentry-tty;
    defaultCacheTtl = 3600;
    maxCacheTtl = 14400;
    defaultCacheTtlSsh = 3600;
    maxCacheTtlSsh = 14400;
  };
}
