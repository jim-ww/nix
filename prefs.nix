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
    flakeDir = "${home}/Projects/nix";
    musicDir = "${home}/Music";
    editor = "nvim";
    browser = "librewolf";
    music-player = "xdg-terminal-exec -- rmpc --clean";
  };
  options = {
    user = strOpt;
    shell = strOpt;
    gitUsername = strOpt;
    gitEmail = strOpt;
    gpgKeyID = strOpt;
    flakeDir = strOpt;
    musicDir = strOpt;
    editor = strOpt;
    browser = strOpt;
    music-player = strOpt;

    packages = mkOption {
      type = types.listOf types.package;
    };
  };
}
