{ config, ... }:
{
  programs.kage = {
    enable = true;
    systemd.enable = true;
    settings = {
      storage.password_cmd = "cat /run/secrets/kage-key";
      attachments_dir = "${config.xdg.configHome}/kage/attachments";
    };
    accounts = [
      {
        alias = "main";
        jidFile = "/run/secrets/kage-acc1";
        passwordFile = "/run/secrets/kage-acc1-passw";
      }
    ];
  };
}
