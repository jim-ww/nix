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
        ./modules/home/git.nix
        ./modules/home/gpg.nix
        ./modules/home/mpd.nix
        ./modules/home/lf.nix
        ./modules/home/battery-low.nix
        ./modules/home/librewolf
        ./modules/home/jujutsu.nix
        ./modules/home/zathura.nix
        ./modules/home/direnv.nix
        ./modules/home/tmux.nix
        ./modules/home/fzf.nix
        ./modules/home/tealdeer.nix
        ./modules/home/servers-healthcheck.nix
        ./modules/home/bwrap.nix
        # ./modules/home/kage.nix
        # inputs.kage.homeManagerModules.default
      ];

      stylix.targets.fzf.enable = false;
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      programs.btop.enable = true;

      gtk.gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      home.sessionVariables = config.env;
      home.shellAliases = config.shellAliases;

      home.username = config.user;
      home.homeDirectory = "/home/${config.user}";
      home.stateVersion = "24.05";
    };
  };
}
