{
  pkgs,
  config,
  ...
}:
let
  passwordStoreDir = "${config.xdg.dataHome}/password-store";
in
{
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_KEY = config.gpgKeyID;
      PASSWORD_STORE_DIR = passwordStoreDir;
    };
    package = pkgs.pass-wayland;
    /*
        .withExtensions (exts: [
        exts.pass-otp
        exts.pass-tomb
      ]);
    */
  };

  services.pass-secret-service = {
    enable = true;
    storePath = passwordStoreDir;
  };
}
