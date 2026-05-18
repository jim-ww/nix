{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
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
    nihongo = {
      url = "github:jim-ww/nihongo";
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
        ./modules/xdg.nix # TODO
        ./modules/bluetooth.nix
        ./modules/docker.nix
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
        ./modules/earlyoom.nix
        ./modules/games.nix
        # ./modules/wireguard.nix
        nur.modules.nixos.default
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        inputs.kickstart-nixvim.nixosModules.default
        {
          programs.nixvim.enable = true;
          # with stablePkgs;
          environment.systemPackages = [
            inputs.nihongo.packages.${system}.default
            (pkgs.callPackage ./modules/pkgs/ani-cli.nix { })
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${user} =
              { config, ... }:
              {
                imports = [
                  ./prefs.nix
                  ./modules/home/pass.nix
                  ./modules/stylix.nix
                  ./modules/home/git.nix
                  ./modules/home/sway.nix
                  ./modules/home/gtk.nix
                  ./modules/home/xdg.nix
                  ./modules/home/gpg.nix
                  ./modules/home/mpd.nix
                  ./modules/home/fish.nix
                  ./modules/home/lf.nix
                  ./modules/home/battery-low.nix
                  ./modules/home/nom.nix
                  ./modules/home/librewolf
                  ./modules/home/distrobox.nix
                  ./modules/home/jujutsu.nix
                  ./modules/home/zathura.nix
                  ./modules/home/direnv.nix
                  ./modules/home/tmux.nix
                  ./modules/home/fzf.nix
                  ./modules/home/tealdeer.nix
                ];
                stylix.targets.fzf.enable = false;
                dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
                programs.btop.enable = true;

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
          ./hardware-config.nix
          ./configuration.nix
          {
            networking.hostName = "nixos";
            networking.networkmanager.wifi.powersave = true;
            services.libinput.touchpad.disableWhileTyping = true;
            #services.geoclue2.enable = true;
          }
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.default
          ./disko.nix
          ./impermanence.nix
          { _module.args.device = "/dev/nvme0n1"; }
        ]
        ++ commonModules;
      };
    };
}
