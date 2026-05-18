{ config, ... }:
{
  programs.tealdeer = {
    enable = true;
    settings.display.use_pager = true;
    settings.updates.auto_update = true;
    settings.cache_dir = "${config.xdg.dataHome}/tealdeer";
  };
}
