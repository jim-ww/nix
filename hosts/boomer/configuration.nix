{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  user = "user";
  fullName = "Пользователь";
  hostname = "home-pc";
  password = "1234";
  timezone = "Europe/Kyiv";
  locale = "ru_RU.UTF-8";
  extraLocales = [
    "en_US.UTF-8/UTF-8"
    "uk_UA.UTF-8/UTF-8"
  ];
  keyboardLayouts = "ru,ua,us";
  keyboardSwitch = "grp:alt_shift_toggle";
  adminKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxGHWa43ZUlie9Tg6cxVkBFA41f2PSqniD3sn7TnDnK jim.w2610@proton.me"
  ];
  tailscaleKeyFile = "/run/secrets/tailscale-boomer";

  cfg = config.boomer;

  tailscaleKey =
    if !lib.inPureEvalMode && builtins.pathExists tailscaleKeyFile then
      pkgs.writeText "tailscale-boomer" (lib.trim (builtins.readFile tailscaleKeyFile))
    else
      null;

  boomerInstall = pkgs.writeShellApplication {
    name = "boomer-install";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
    ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "usage: boomer-install <disk>" >&2
        lsblk -dpo NAME,SIZE,TYPE,MODEL >&2
        exit 1
      fi
      disk=$(readlink -f "$1")
      if [ ! -b "$disk" ]; then
        echo "not a block device: $1" >&2
        exit 1
      fi
      ln -sfn "$disk" /dev/boomer-disk
      ${cfg.installed.config.system.build.diskoScript} --yes-wipe-all-disks
      ${config.system.build.nixos-install}/bin/nixos-install --root /mnt \
        --system ${cfg.installed.config.system.build.toplevel} \
        --no-root-passwd --no-channel-copy
      umount -R /mnt || true
    '';
  };

  desktopIcons = [
    "firefox.desktop"
    "writer.desktop"
    "calc.desktop"
    "org.gnome.SimpleScan.desktop"
    "org.gnome.Software.desktop"
    "gimp.desktop"
    "org.telegram.desktop.desktop"
    "im.dino.Dino.desktop"
    "org.gnome.Calculator.desktop"
  ];

  desktopIconsScript = pkgs.writeShellApplication {
    name = "desktop-icons";
    runtimeInputs = with pkgs; [
      xdg-user-dirs
      coreutils
    ];
    text = ''
      state="$HOME/.local/state/desktop-icons"
      mkdir -p "$state"
      xdg-user-dirs-update
      dir=$(xdg-user-dir DESKTOP)
      mkdir -p "$dir"
      for app in ${lib.escapeShellArgs desktopIcons}; do
        [ -e "$state/$app" ] && continue
        src=/run/current-system/sw/share/applications/$app
        [ -e "$src" ] || continue
        if [ ! -e "$dir/$app" ]; then
          install -m 0755 "$(readlink -f "$src")" "$dir/$app"
        fi
        touch "$state/$app"
      done
      vlcrc="$HOME/.config/vlc/vlcrc"
      if [ ! -e "$vlcrc" ]; then
        mkdir -p "$(dirname "$vlcrc")"
        printf '[qt]\nqt-privacy-ask=0\n' >"$vlcrc"
      fi
    '';
  };

  mimeDefaults = apps: lib.concatMapAttrs (app: types: lib.genAttrs types (_: app)) apps;
in
{
  imports = [ (modulesPath + "/profiles/all-hardware.nix") ];

  options.boomer = {
    iso = lib.mkEnableOption "the live USB variant";
    installed = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
    };
  };

  config = lib.mkMerge [
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;
      hardware.enableAllFirmware = true;
      hardware.bluetooth.enable = true;

      networking.hostName = hostname;
      networking.networkmanager.enable = true;
      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      time.timeZone = timezone;
      i18n.defaultLocale = locale;
      i18n.extraLocales = extraLocales;
      console.useXkbConfig = true;

      services.xserver = {
        enable = true;
        xkb = {
          layout = keyboardLayouts;
          options = keyboardSwitch;
        };
        desktopManager.cinnamon = {
          enable = true;
          extraGSettingsOverrides = ''
            [org.nemo.desktop]
            home-icon-visible=true
            computer-icon-visible=true
            trash-icon-visible=true

            [org.cinnamon.desktop.input-sources]
            sources=[${
              lib.concatMapStringsSep ", " (l: "('xkb', '${l}')") (lib.splitString "," keyboardLayouts)
            }]
            xkb-options=['${keyboardSwitch}']
          '';
        };
      };
      services.displayManager.autoLogin = {
        enable = true;
        inherit user;
      };

      environment.etc."xdg/autostart/desktop-icons.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Desktop icons
        Exec=${desktopIconsScript}/bin/desktop-icons
        NoDisplay=true
      '';

      services.blueman.enable = true;
      programs.system-config-printer.enable = true;

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
      };
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      zramSwap.enable = true;
      services.earlyoom.enable = true;

      services.printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          hplip
        ];
      };
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };

      services.flatpak.enable = true;
      systemd.services.flathub = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.flatpak ];
        script = "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
        serviceConfig = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = 60;
        };
      };
      systemd.services.flatpak-update = {
        path = [ pkgs.flatpak ];
        script = "flatpak update --system --noninteractive -y";
        serviceConfig.Type = "oneshot";
      };
      systemd.timers.flatpak-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("org.freedesktop.Flatpak.") == 0 && subject.user == "${user}") {
            return polkit.Result.YES;
          }
        });
      '';

      programs.firefox = {
        enable = true;
        languagePacks = [
          "ru"
          "uk"
          "en-US"
        ];
        preferencesStatus = "default";
        preferences = {
          "intl.locale.requested" = "";
          "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
          "browser.aboutwelcome.enabled" = false;
        };
        policies = {
          ExtensionSettings."uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          SkipTermsOfUse = true;
          NoDefaultBookmarks = true;
          DisplayBookmarksToolbar = "always";
          Homepage = {
            StartPage = "previous-session";
            Locked = false;
          };
          FirefoxHome = {
            SponsoredTopSites = false;
            SponsoredStories = false;
            SponsoredPocket = false;
            Stories = false;
            Pocket = false;
            Snippets = false;
            Locked = false;
          };
          FirefoxSuggest = {
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            Locked = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            MoreFromMozilla = false;
            FirefoxLabs = false;
            SkipOnboarding = true;
            WhatsNew = false;
            UrlbarInterventions = false;
            Locked = false;
          };
          GenerativeAI = {
            Enabled = false;
            Locked = false;
          };
        };
      };

      fonts.packages = with pkgs; [
        corefonts
        vista-fonts
        liberation_ttf
        noto-fonts
        noto-fonts-color-emoji
      ];

      environment.systemPackages = with pkgs; [
        libreoffice
        hunspell
        hunspellDicts.ru_RU
        hunspellDicts.uk_UA
        hunspellDicts.en_US
        vlc
        gimp
        simple-scan
        telegram-desktop
        dino
        wineWow64Packages.stableFull
        gnome-software
        x11vnc

        tmux
        btop
        fd
        ripgrep
        fzf
        lf
        gdu
        file
        tree
        curl
        wget
        rsync
        _7zz-rar
        tealdeer
        smartmontools
        lm_sensors
        inxi
        lsof
        dnsutils
        iperf3
        pciutils
        usbutils
        parted
        gptfdisk
        e2fsprogs
        dosfstools
        testdisk
      ];

      xdg.mime.defaultApplications = mimeDefaults {
        "xviewer.desktop" = [
          "image/jpeg"
          "image/png"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
          "image/svg+xml"
          "image/heic"
          "image/avif"
        ];
        "xreader.desktop" = [
          "application/pdf"
          "application/postscript"
          "image/vnd.djvu"
        ];
        "vlc.desktop" = [
          "video/mp4"
          "video/x-matroska"
          "video/webm"
          "video/x-msvideo"
          "video/quicktime"
          "video/mpeg"
          "video/x-flv"
          "video/3gpp"
          "video/x-ms-wmv"
          "audio/mpeg"
          "audio/mp4"
          "audio/x-m4a"
          "audio/aac"
          "audio/wav"
          "audio/x-wav"
          "audio/ogg"
          "audio/opus"
          "audio/flac"
          "audio/x-ms-wma"
        ];
        "org.x.editor.desktop" = [ "text/plain" ];
        "writer.desktop" = [
          "application/msword"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.oasis.opendocument.text"
          "application/rtf"
        ];
        "calc.desktop" = [
          "application/vnd.ms-excel"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.oasis.opendocument.spreadsheet"
          "text/csv"
        ];
        "impress.desktop" = [
          "application/vnd.ms-powerpoint"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.oasis.opendocument.presentation"
        ];
        "org.gnome.FileRoller.desktop" = [
          "application/zip"
          "application/x-7z-compressed"
          "application/vnd.rar"
          "application/x-rar"
          "application/x-tar"
          "application/gzip"
          "application/x-compressed-tar"
          "application/x-xz-compressed-tar"
        ];
        "firefox.desktop" = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        "nemo.desktop" = [ "inode/directory" ];
        "wine.desktop" = [
          "application/x-ms-dos-executable"
          "application/x-msdownload"
          "application/vnd.microsoft.portable-executable"
          "application/x-dosexec"
          "application/x-ms-ne-executable"
          "application/x-msi"
          "application/x-ms-shortcut"
          "application/x-bat"
        ];
        "org.telegram.desktop.desktop" = [ "x-scheme-handler/tg" ];
        "im.dino.Dino.desktop" = [ "x-scheme-handler/xmpp" ];
      };

      programs.bash.blesh.enable = true;
      programs.neovim = {
        enable = true;
        vimAlias = true;
        defaultEditor = true;
        configure.customLuaRC = ''
          vim.o.number = true
          vim.o.relativenumber = true
          vim.o.clipboard = "unnamedplus"
          vim.o.undofile = true
          vim.o.swapfile = false
          vim.opt.path:append("**")
          vim.o.ignorecase = true
          vim.o.smartcase = true
          vim.o.breakindent = true
          vim.o.linebreak = true
          vim.o.splitright = true
          vim.o.splitbelow = true
          vim.o.cursorline = true
          vim.o.scrolloff = 10
          vim.o.confirm = true
          vim.o.inccommand = "split"
          vim.o.list = true
          vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

          vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
          vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
          for _, k in ipairs({ "h", "j", "k", "l" }) do
            vim.keymap.set("n", "<C-" .. k .. ">", "<C-w><C-" .. k .. ">")
          end

          vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })
          vim.api.nvim_create_autocmd("BufReadPost", { command = [[silent! normal! g`"]] })
          vim.api.nvim_create_autocmd("BufWritePre", { callback = function(a) vim.fn.mkdir(vim.fn.fnamemodify(a.file, ":p:h"), "p") end })
        '';
      };
      environment.variables.LESS = "-R";
      environment.shellAliases =
        let
          ls = "ls -h --group-directories-first --color=auto";
        in
        {
          v = "$EDITOR";
          c = "clear";
          l = ls;
          ll = "${ls} -l";
          la = "${ls} -A";
          rm = "rm -v";
          cp = "cp -v";
          mv = "mv -v";
          "7z" = "7zz";
          ns = lib.getExe pkgs.nix-search-cli;
          nsp = "nix-shell -p";
        };

      users.users.${user} = {
        isNormalUser = true;
        uid = 1000;
        description = fullName;
        initialPassword = password;
        extraGroups = [
          "networkmanager"
          "audio"
          "video"
          "lp"
          "scanner"
        ];
      };
      users.users.root.openssh.authorizedKeys.keys = adminKeys;

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      services.tailscale = {
        enable = true;
        authKeyFile = tailscaleKey;
        extraUpFlags = [ "--hostname=${config.networking.hostName}" ];
      };

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      system.stateVersion = "26.11";
    }

    (lib.mkIf (!cfg.iso) {
      disko.devices.disk.main = {
        type = "disk";
        device = "/dev/boomer-disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5;
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_PART_ENTRY_NAME}=="disk-main-root", RUN+="${pkgs.coreutils}/bin/ln -sfn /dev/$parent /dev/boomer-disk"
      '';
    })

    (lib.mkIf cfg.iso {
      networking.hostName = lib.mkForce "${hostname}-usb";
      services.openssh.openFirewall = lib.mkForce true;
      system.extraDependencies = [
        cfg.installed.config.system.build.toplevel
        cfg.installed.config.system.build.diskoScript
      ];
      environment.systemPackages = [ boomerInstall ];
    })
  ];
}
