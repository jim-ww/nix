{ config, ... }:
let
  username = config.gitUsername;
  email = config.gitEmail;
in
{
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    ignores = [
      "CLAUDE.md"
      "CLAUDE.local.md"
      ".claude/settings.local.json"
    ];
    settings = {
      user.name = username;
      user.email = email;
      pull.rebase = true;

      color.ui = true;
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      safe.directory = [ config.flakeDir ];
      url."ssh://git@github.com/${username}".insteadOf = "https://github.com/${username}";

      user.signingkey = config.gpgKeyID;
      commit.gpgsign = true; # sign all commits by default

      submodule.recurse = true;
      push.recurseSubmodules = "on-demand";
    };
  };
}
