{ config, ... }:
{
  sops.secrets = {
    rclone-mega-user.owner = config.user;
    rclone-mega-password.owner = config.user;
    rclone-drive-token.owner = config.user;
    rclone-pcloud-token.owner = config.user;
    rclone-koofr-user.owner = config.user;
    rclone-koofr-password.owner = config.user;
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
      drive = {
        secrets.token = config.sops.secrets.rclone-drive-token.path;
        config = {
          type = "drive";
          scope = "drive";
        };
      };
    };
  };
}
