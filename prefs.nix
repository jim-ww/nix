{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  home = "/home/${config.user}";

  strOpt = mkOption { type = types.str; };
in
{
  imports = [
    ./env.nix
    ./aliases.nix
  ];

  config = {
    user = "jim";
    shell = "bash";
    gitUsername = "jim-ww";
    gitEmail = "jim.w2610@proton.me";
    gpgKeyID = "84E78B81883125DEF4FFBD7735AE71B304C67013";
    packages = import ./pkgs.nix { inherit pkgs; };
    wallpaper.command = "swaybg -i $NH_FLAKE/wallpaper -m fill & disown";
    flakeDir = "${home}/Projects/nix";
    musicDir = "${home}/Music";
    editor = "nvim";
    browser = "librewolf";
    music-player = "xdg-terminal-exec -- rmpc --clean";
    swaylock = "${lib.getExe pkgs.swaylock} -efkli ${config.flakeDir}/wallpaper && ${config.shellAliases.umount-personal}";
  };
  options = {
    user = strOpt;
    shell = strOpt;
    gitUsername = strOpt;
    gitEmail = strOpt;
    gpgKeyID = strOpt;
    wallpaper.command = strOpt;
    flakeDir = strOpt;
    musicDir = strOpt;
    editor = strOpt;
    browser = strOpt;
    music-player = strOpt;
    swaylock = strOpt;

    packages = mkOption {
      type = types.listOf types.package;
    };
  };
}
