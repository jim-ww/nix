{ pkgs, ... }: {
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml"; # -dark / -terminal-dark
  stylix.polarity = "dark";
  stylix.cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors.overrideAttrs (_: {
      buildPhase = ''
        runHook preBuild
        ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Classic -n 'Bibata-Modern-Classic' -c 'Black and rounded edge Bibata XCursors'
        runHook postBuild
      '';
    });
    size = 20;
  };
  stylix.opacity =
    let
      opacity = 0.95;
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
      applications = 18; # 16
      desktop = 18; # 12;
      popups = 12;
      terminal = 10;
    };
  };

  stylix.icons = {
    enable = true;
    package = pkgs.paper-icon-theme;
    dark = "Paper";
    light = "Paper";
  };

  stylix.targets.kmscon.enable = false;
}
