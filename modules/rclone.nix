{ config, ... }:
{
  sops.secrets = {
    rclone-mega-user.owner = config.user;
    rclone-mega-password.owner = config.user;
    rclone-drive-token.owner = config.user;
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
        secrets.token = config.sops.secrets.rclone-drive-token.path;
        config = {
          type = "drive";
          scope = "drive";
        };
      };
    };
  };
}
