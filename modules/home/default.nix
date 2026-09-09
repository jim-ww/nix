{ config, ... }:
{
  imports = [
    ../../prefs.nix
    ./git.nix
    ./gpg.nix
    ./mpd.nix
    ./lf.nix
    ./battery-low.nix
    ./librewolf
    ./jujutsu.nix
    ./zathura.nix
    ./direnv.nix
    ./tmux.nix
    ./fzf.nix
    ./tealdeer.nix
    ./servers-healthcheck.nix
    ./bwrap.nix
    # ./kage.nix
    # inputs.kage.homeManagerModules.default
  ];

  stylix.targets.fzf.enable = false;
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  programs.btop.enable = true;

  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = 1;
  };

  home.packages = config.packages;
  home.sessionVariables = config.env;
  home.shellAliases = config.shellAliases;

  home.username = config.user;
  home.homeDirectory = "/home/${config.user}";
  home.stateVersion = "24.05";
}
