{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.load_dotenv = true;
    config = {
      hide_env_diff = true;
      warn_timeout = 0;
    };
  };
}
