{
  pkgs,
  config,
  ...
}:
{
  services.swayidle = {
    enable = true;

    timeouts = [
      # lock screen & off displays after 10 minutes of inactivity
      {
        timeout = 60 * 10;
        command = ''${config.swaylock} && swaymsg "output * power off"'';
        resumeCommand = ''swaymsg "output * power on"'';
      }
      # suspend after 30 minutes of inactivity
      {
        timeout = 60 * 30;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];

    events = {
      before-sleep = config.swaylock;
      lock = "lock";
    };
  };
}
