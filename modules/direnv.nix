{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    nix-direnv.enable = true;
    config.load_dotenv = true;
    config = {
      hide_env_diff = true;
      warn_timeout = 0;
    };
  };

  programs.bash.initExtra = lib.mkAfter ''
    source ${pkgs.runCommand "direnv-hook.bash" { } "${lib.getExe config.programs.direnv.package} hook bash > $out"}
  '';
}
