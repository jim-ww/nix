{ config, ... }: {
  preservation = {
    enable = true;

    preserveAt."/persistent" = {
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/bluetooth";
          mode = "0700";
        }
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        {
          directory = "/var/lib/ollama";
          mode = "0700";
          group = "ollama";
          user = "ollama";
        }
        {
          directory = "/tmp"; # to avoid large blobs taking all RAM
          mode = "1777";
        }
        "/var/log"
        "/var/lib/systemd/timers"
        "/etc/ssh"
      ];

      users."${config.user}" = {
        directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }

          {
            directory = ".gnupg";
            mode = "0700";
          }

          {
            directory = ".local/share/gnupg";
            mode = "0700";
          }

          {
            directory = ".pki";
            mode = "0700";
          }

          {
            directory = ".config/jj";
            mode = "0700";
          }

          {
            directory = ".config/transmission";
            mode = "0700";
          }

          {
            directory = ".local/share/bash";
            mode = "0700";
          }

          {
            directory = ".librewolf";
            mode = "0700";
          }

          {
            directory = ".config/.wrangler";
            mode = "0700";
          }

          {
            directory = ".config/keepassxc";
            mode = "0700";
          }

          {
            directory = ".config/gh";
            mode = "0700";
          }

          {
            directory = ".config/transmission-remote-gtk";
            mode = "0700";
          }

          {
            directory = ".local/share/unison";
            mode = "0700";
          }

          {
            directory = ".local/state/nvim";
            mode = "0700";
          }

          "Archive"
          "Documents"
          "Downloads"
          "Games"
          "Music"
          "Pictures"
          "Projects"
          "Videos"
          ".local/share/Trash"
          ".npm" # doesn't fit in RAM
          ".barony"
          ".shared-ringdb"
          ".config/kage"
          ".config/FreeTube"
          ".local/share/go"
          ".local/share/Anki2" # TODO
          ".local/share/direnv"
          ".local/share/umu"
          ".local/share/pnpm"
          ".local/share/nihongo"
          ".local/share/anitui"
          ".local/share/zathura"
          ".local/share/tealdeer"
          ".local/share/charshare"
          ".local/share/itpec-sensei"
          ".config/distrobox"
          ".claude"
          ".cache" # to avoid large blobs taking all RAM
        ];
        files = [
          {
            file = ".claude.json";
            mode = "0600";
          }
        ];
      };
    };
  };
}
