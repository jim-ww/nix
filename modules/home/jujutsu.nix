{ config, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      signing = {
        behavior = "drop";
        backend = "gpg";
        key = config.gpgKeyID;
      };
      revsets = {
        sign = "mine() & mutable() & ~trunk()";
      };
      user = {
        name = config.programs.git.settings.user.name;
        email = config.programs.git.settings.user.email;
      };
      ui = {
        default-command = "status";
        show-cryptographic-signatures = true;
      };
    };
  };
}
