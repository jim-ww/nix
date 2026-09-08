{ config, ... }: {
  preservation = {
    enable = true;
    preserveAt."/persistent".users."${config.user}" = {
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".local/share/gnupg";
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
        ".barony"
        ".config/kage"
        ".config/FreeTube"
        ".local/share/anitui"
        ".local/share/charshare"
        ".local/share/itpec-sensei"
      ];
    };
    # volatile state, not snapshotted
    preserveAt."/state" = {
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
        "/var/lib/systemd/timers"
        "/etc/ssh"
        "/var/log"
        {
          directory = "/tmp";
          mode = "1777";
        }
      ];

      users."${config.user}" = {
        directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".config/transmission-remote-gtk";
            mode = "0700";
          }
          {
            directory = ".local/share/bash";
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
            directory = ".config/gh";
            mode = "0700";
          }
          ".cache"
          ".npm"
          ".librewolf"
          ".shared-ringdb"
          ".local/share/Trash"
          ".local/share/direnv"
          ".local/share/umu"
          ".local/share/nihongo"
          ".local/share/zathura"
          ".local/share/tealdeer"
          ".local/state/nvim"
          ".local/share/pnpm"
          ".local/share/go"
          ".config/distrobox"
          ".claude"
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
