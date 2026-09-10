{
  stylix.targets.noctalia.enable = false;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = ./noctalia.toml;
  };
}
