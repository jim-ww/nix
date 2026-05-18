{ pkgs, ... }:
let
  myTokyoNight = {
    base00 = "24283b";
    base01 = "1f2335";
    base02 = "292e42";
    base03 = "565f89";
    base04 = "a9b1d6";
    base05 = "c0caf5";
    base06 = "c0caf5";
    base07 = "c0caf5";
    base08 = "f7768e";
    base09 = "ff9e64";
    base0A = "e0af68";
    base0B = "9ece6a";
    base0C = "1abc9c";
    base0D = "41a6b5";
    base0E = "bb9af7";
    base0F = "ff007c";
  };
in
{
  stylix.enable = true;
  #stylix.image = "${../assets/wallpaper}";
  stylix.base16Scheme = myTokyoNight;
  stylix.polarity = "dark";
  stylix.cursor = {
    name = "Bibata-Modern-Classic"; # "Vimix Cursors";
    package = pkgs.bibata-cursors; # pkgs.vimix-cursor-theme;
    size = 20;
  };
  stylix.opacity =
    let
      opacity = 0.95; # 0.8; # 1.0e-3;
    in
    {
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
      applications = 14;
      desktop = 12;
      popups = 12;
      terminal = 10;
    };
  };
}
