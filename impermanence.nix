{config, ...}: {
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
          directory = "/var/lib/docker";
          mode = "0710";
        }
        {
          directory = "/var/lib/tor";
          mode = "0700";
        }
        # {
        #   directory = "/var/lib/i2pd";
        #   mode = "0700";
        # }
        # {
        #   directory = "/var/lib/ipfs";
        #   mode = "0700";
        # }
        "/var/log"
        "/var/lib/systemd/timers"
        "/etc/ssh"
      ];

      files = [
        "/var/lib/vnstat/vnstat.db"
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
            directory = ".config/Element";
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
            directory = ".local/share/fish";
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
            directory = ".codex";
            mode = "0700";
          }

          {
            directory = ".config/turso";
            mode = "0700";
          }

          {
            directory = ".config/keepassxc";
            mode = "0700";
          }

          {
            directory = ".local/share/keyrings";
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
            directory = ".local/share/dino";
            mode = "0700";
          }

          {
            directory = ".config/docker";
            mode = "0700";
          }

          {
            directory = ".config/monero-project";
            mode = "0700";
          }

          {
            directory = ".local/share/bitmonero";
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
          ".bitmonero"
          ".steam"
          ".shared-ringdb"
          ".config/FreeTube"
          ".config/obs-studio"
          ".local/share/go"
          ".local/share/Anki2"
          ".local/share/direnv"
          ".local/share/umu"
          ".local/share/Steam"
          ".local/share/pnpm"
          ".local/share/berg-cli"
          ".local/share/nihongo"
          ".local/share/anitui"
          ".local/share/zathura"
          ".local/share/tealdeer"
          ".config/nom"
          ".config/distrobox"

          # ".local/share/osu"
          # ".local/share/zed"
          # ".local/share/distrobox"
        ];
      };
    };
  };
}
