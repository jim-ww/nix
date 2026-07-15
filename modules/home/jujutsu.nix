{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      signing = {
        behavior = "own";
        backend = "gpg";
        key = config.gpgKeyID;
      };
      user = {
        name = config.programs.git.settings.user.name;
        email = config.programs.git.settings.user.email;
      };
      ui.default-command = "status";
    };
  };
}
