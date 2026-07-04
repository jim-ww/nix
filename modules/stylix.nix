{pkgs, ...}: {
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml"; # -dark / -terminal-dark
  stylix.polarity = "dark";
  stylix.cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };
  stylix.opacity = let
    opacity = 0.95;
  in {
    applications = opacity;
    desktop = opacity;
    popups = opacity;
    terminal = opacity;
  };
  stylix.fonts = {
    monospace = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    };
    sansSerif = {
      name = "DeaVu Sans";
      package = pkgs.dejavu_fonts;
    };
    serif = {
      name = "DejaVu Serif";
      package = pkgs.dejavu_fonts;
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
    sizes = {
      applications = 18; #16
      desktop = 18; #12;
      popups = 12;
      terminal = 10;
    };
  };

  stylix.icons = {
    enable = true;
    package = pkgs.paper-icon-theme; #pkgs.papirus-icon-theme; # pkgs.adwaita-icon-theme;
    dark = "Paper"; # "Papirus-Dark"; # "Adwaita";
    light = "Paper"; # "Papirus-Light";
  };

  stylix.targets.kmscon.enable = false;
}
