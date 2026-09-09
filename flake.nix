{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
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
    nixvim = {
      url = "github:nix-community/nixvim";
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
    anitui = {
      url = "github:jim-ww/anitui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kage = {
      url = "github:jim-ww/kage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bdraw = {
      url = "github:jim-ww/bdraw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    todo = {
      url = "github:jim-ww/todo";
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
        ./modules/firewall.nix
        ./modules/pipewire.nix
        ./modules/stylix.nix
        ./modules/japanese.nix
        ./modules/user.nix
        ./modules/sops.nix
        ./modules/tlp.nix
        # ./modules/nix-ld.nix
        ./modules/games.nix
        ./modules/wireguard.nix
        ./modules/vpn.nix
        ./modules/xdg.nix
        ./modules/ollama.nix
        ./modules/podman.nix
        ./modules/rclone.nix
        ./modules/sway.nix
        ./modules/bash.nix
        ./home.nix
        nur.modules.nixos.default
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        inputs.nixvim.nixosModules.nixvim
        ./modules/nixvim
        {
          programs.nixvim.enable = true;
          # with stablePkgs;
          packages = map (n: inputs.${n}.packages.${system}.default) [
            "nihongo"
            "charshare"
            "itpec-sensei"
            "gtr"
            "anitui"
            "bdraw"
            "kage"
            "todo"
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
          };
          nixpkgs.overlays = [
            nur.overlays.default
            inputs.ani-cli.overlays.default
          ];
        }
      ];
    in
    {
      packages.${system} = {
        nvim = self.nixosConfigurations.nixos.config.programs.nixvim.build.package;
        default = self.packages.${system}.nvim;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.nvim}/bin/nvim";
      };

      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            system
            self
            ;
        };
        modules = [
          ./configuration.nix
          ./hardware-config.nix
          ./disko.nix
          ./impermanence.nix
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.default
        ]
        ++ commonModules;
      };
    };
}
