{
  config,
  lib,
  ...
}:
{
  options.hm = lib.mkOption {
    type = lib.types.deferredModule;
    default = { };
  };

  config = {
    home-manager.users.${config.user} = config.hm;

    hm = {
      imports = [
        ./prefs.nix
        ./modules/git.nix
        ./modules/gpg.nix
        ./modules/mpd.nix
        ./modules/lf.nix
        ./modules/battery-low.nix
        ./modules/librewolf
        ./modules/jujutsu.nix
        ./modules/zathura.nix
        ./modules/direnv.nix
        ./modules/tmux.nix
        ./modules/fzf.nix
        ./modules/tealdeer.nix
        ./modules/servers-healthcheck.nix
        ./modules/bwrap.nix
        ./modules/pnpm.nix
        ./modules/theme.nix
        ./modules/foot.nix
        ./modules/noctalia.nix
        # ./modules/kage.nix
        # inputs.kage.homeManagerModules.default
      ];

      stylix.targets.fzf.enable = false;
      stylix.targets.qt.enable = false;
      programs.btop.enable = true;

      home.sessionVariables = config.env;
      home.shellAliases = config.shellAliases;

      home.username = config.user;
      home.homeDirectory = "/home/${config.user}";
      home.stateVersion = "24.05";
    };
  };
}
