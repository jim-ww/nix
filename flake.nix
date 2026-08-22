{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix"; # TODO: moved to nix-community
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kickstart-nixvim = {
      url = "path:./modules/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ani-cli.url = "path:./pkgs/ani-cli";
    nihongo = {
      url = "github:jim-ww/nihongo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pomodoro-go = {
      url = "github:jim-ww/pomodoro-go";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shiraberu = {
      url = "github:jim-ww/shiraberu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    charshare = {
      url = "github:jim-ww/charshare";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    itpec-sensei = {
      url = "github:jim-ww/itpec-sensei";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gtr = {
      url = "github:jim-ww/gtr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gowebwrap = {
      url = "github:jim-ww/gowebwrap";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anitui = {
      url = "github:jim-ww/anitui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kage = {
      url = "github:jim-ww/kage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nur,
      #nixpkgs-stable,
      home-manager,
      stylix,
      sops-nix,
      ...
    }@inputs:
    let
      user = "jim";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      #stablePkgs = nixpkgs-stable.legacyPackages.${system};
      commonModules = [
        ./prefs.nix
        ./modules/bluetooth.nix
        ./modules/earlyoom.nix
        ./modules/firewall.nix
        ./modules/graphics.nix
        ./modules/pipewire.nix
        ./modules/autologin.nix
        ./modules/stylix.nix
        ./modules/japanese.nix
        ./modules/user.nix
        ./modules/sops.nix
        ./modules/tlp.nix
        ./modules/nix-ld.nix
        ./modules/games.nix
        ./modules/wireguard.nix
        ./modules/keyring.nix
        ./modules/xdg.nix
        ./modules/ollama.nix
        ./modules/podman.nix
        # ./modules/docker.nix
        nur.modules.nixos.default
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        inputs.kickstart-nixvim.nixosModules.default
        {
          programs.nixvim.enable = true;
          # with stablePkgs;
          packages = [
            inputs.nihongo.packages.${system}.default
            inputs.pomodoro-go.packages.${system}.default
            inputs.shiraberu.packages.${system}.default
            inputs.charshare.packages.${system}.default
            inputs.itpec-sensei.packages.${system}.default
            inputs.gowebwrap.packages.${system}.default
            inputs.gtr.packages.${system}.default
            inputs.anitui.packages.${system}.default
            inputs.kage.packages.${system}.default
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${user} = { config, ... }: {
              imports = [
                ./prefs.nix
                ./modules/home/git.nix
                ./modules/home/sway.nix
                ./modules/home/xdg.nix
                ./modules/home/gpg.nix
                ./modules/home/mpd.nix
                ./modules/home/lf.nix
                ./modules/home/battery-low.nix
                ./modules/home/librewolf
                ./modules/home/distrobox.nix
                ./modules/home/jujutsu.nix
                ./modules/home/zathura.nix
                ./modules/home/direnv.nix
                ./modules/home/tmux.nix
                ./modules/home/fzf.nix
                ./modules/home/tealdeer.nix
                ./modules/home/protonvpn.nix
                ./modules/home/go.nix
                ./modules/home/servers-healthcheck.nix
                ./modules/home/bash.nix
                ./modules/home/bwrap.nix
              ];
              stylix.targets.fzf.enable = false;
              dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
              programs.btop.enable = true;

              # TODO why stylix doesnt set that?
              gtk.gtk3.extraConfig = {
                gtk-application-prefer-dark-theme = 1;
              };

              home.packages = config.packages;
              home.sessionVariables = config.env;
              home.shellAliases = config.shellAliases;

              home.username = config.user;
              home.homeDirectory = "/home/${config.user}";
              home.stateVersion = "24.05";
              #_module.args.stablePkgs = stablePkgs;
            };
          };
          nixpkgs.overlays = [
            nur.overlays.default
            inputs.ani-cli.overlays.default
          ];
        }
      ];
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            system
            self
            ;
        };
        modules = [
          ./hosts/nixos
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.default
        ]
        ++ commonModules;
      };
    };
}
