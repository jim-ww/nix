{
  config,
  pkgs,
  lib,
  ...
}:
let
  configPass = config.sops.secrets.rclone-config-pass.path;
in
{
  sops.secrets = {
    rclone-config-pass.owner = config.user;
    rclone-mega-user.owner = config.user;
    rclone-mega-password.owner = config.user;
    rclone-drive-token.owner = config.user;
    rclone-pcloud-token.owner = config.user;
    rclone-koofr-user.owner = config.user;
    rclone-koofr-password.owner = config.user;
    rclone-filen-email.owner = config.user;
    rclone-filen-password.owner = config.user;
    rclone-filen-api-key.owner = config.user;
  };

  hm = {
    # rclone.conf is rendered in plaintext on every activation, so re-encrypt it
    # once the secrets have been injected.
    systemd.user.services.rclone-config.Service.ExecStartPost =
      ''${lib.getExe pkgs.rclone} config encryption set --password-command "cat ${configPass}"'';

    programs.rclone = {
      enable = true;
      remotes = {
        mega = {
          secrets = {
            user = config.sops.secrets.rclone-mega-user.path;
            pass = config.sops.secrets.rclone-mega-password.path;
          };
          config.type = "mega";
        };
        pcloud = {
          secrets.token = config.sops.secrets.rclone-pcloud-token.path;
          config = {
            type = "pcloud";
            hostname = "eapi.pcloud.com";
          };
        };
        koofr = {
          secrets = {
            user = config.sops.secrets.rclone-koofr-user.path;
            password = config.sops.secrets.rclone-koofr-password.path;
          };
          config = {
            type = "koofr";
            provider = "koofr";
          };
        };
        filen = {
          secrets = {
            email = config.sops.secrets.rclone-filen-email.path;
            password = config.sops.secrets.rclone-filen-password.path;
            api_key = config.sops.secrets.rclone-filen-api-key.path;
          };
          config.type = "filen";
        };
        drive = {
          secrets.token = config.sops.secrets.rclone-drive-token.path;
          config = {
            type = "drive";
            scope = "drive";
          };
        };
      };
    };
  };
}
