{ config, ... }:
{
  services.getty = {
    autologinUser = config.user;
    autologinOnce = true;
  };
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';
}
