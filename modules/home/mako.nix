{ pkgs, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      border-radius = 7;
      padding = "10";
      margin = "5";
      default-timeout = 3500;
      ignore-timeout = false;
      icons = true;
      on-notify = "exec ${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play -i message -V 15";
      max-history = 30;
    };
  };
}
