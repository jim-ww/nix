{
  programs.mpv = {
    enable = true;
    bindings = {
      "Ctrl+r" = "cycle-values video-rotate 90 180 270 0";
      "Ctrl+R" = "cycle-values video-rotate 270 180 90 0";
    };
  };
}
