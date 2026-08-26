{
  programs.rofi = {
    enable = true;
    #package = pkgs.rofi-wayland;
    #theme = lib.mkForce "sidebar"; #"material";
    extraConfig = {
      case-sensitive = false;
      display-drun = "Apps:";
      modi = [
        "drun"
        "run"
      ];
      show-icons = true;
    };
  };
}
