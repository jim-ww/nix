{ config, ... }:
{
  sops.secrets = {
    rclone-mega-user.owner = config.user;
    rclone-mega-password.owner = config.user;
    rclone-drive-token.owner = config.user;
    rclone-drive-client-id.owner = config.user;
    rclone-drive-client-secret.owner = config.user;
  };

  home-manager.users.${config.user}.programs.rclone = {
    enable = true;
    remotes = {
      mega = {
        secrets = {
          user = config.sops.secrets.rclone-mega-user.path;
          pass = config.sops.secrets.rclone-mega-password.path;
        };
        config.type = "mega";
      };
      drive = {
        secrets = {
          token = config.sops.secrets.rclone-drive-token.path;
          client_id = config.sops.secrets.rclone-drive-client-id.path;
          client_secret = config.sops.secrets.rclone-drive-client-secret.path;
        };
        config = {
          type = "drive";
          scope = "drive";
        };
      };
    };
  };
}
