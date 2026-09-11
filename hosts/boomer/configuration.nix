{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  desktop = "xfce";
  user = "user";
  fullName = "Пользователь";
  hostname = "boomer";
  password = "1234";
  timezone = "Europe/Kyiv";
  locale = "ru_RU.UTF-8";
  extraLocales = [
    "en_US.UTF-8/UTF-8"
    "uk_UA.UTF-8/UTF-8"
  ];
  keyboardLayouts = "us,ru,ua";
  keyboardSwitch = "grp:alt_shift_toggle";
  adminName = "Jim";
  adminKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxGHWa43ZUlie9Tg6cxVkBFA41f2PSqniD3sn7TnDnK jim.w2610@proton.me"
  ];
  tailscaleKeyFile = "/run/secrets/tailscale-boomer";

  cfg = config.boomer;
  isPlasma = desktop == "plasma";
  isX11 = !isPlasma;

  tailscaleKey =
    if !lib.inPureEvalMode && builtins.pathExists tailscaleKeyFile then
      pkgs.writeText "tailscale-boomer" (lib.trim (builtins.readFile tailscaleKeyFile))
    else
      null;

  boomerHelp = pkgs.writeShellApplication {
    name = "boomer-help";
    runtimeInputs = with pkgs; [
      tailscale
      jq
      qrencode
      yad
      coreutils
      gnugrep
    ];
    text = ''
      connected() {
        [ "$(tailscale status --json 2>/dev/null | jq -r .BackendState)" = "Running" ]
      }
      if connected; then
        yad --center --width=420 --title="Помощь" --button="OK:0" \
          --text="Компьютер подключён. Позвоните ${adminName}, он сможет помочь."
        exit 0
      fi
      log=$(mktemp)
      tailscale up --reset --hostname=${config.networking.hostName} >"$log" 2>&1 &
      url=""
      for _ in $(seq 60); do
        url=$(grep -o 'https://login.tailscale.com/[^[:space:]]*' "$log" | head -n1 || true)
        if [ -n "$url" ] || connected; then break; fi
        sleep 1
      done
      if connected; then
        yad --center --width=420 --title="Помощь" --button="OK:0" \
          --text="Компьютер подключён. Позвоните ${adminName}, он сможет помочь."
      elif [ -n "$url" ]; then
        png=$(mktemp --suffix=.png)
        qrencode -s 10 -m 2 -o "$png" "$url"
        yad --center --title="Помощь" --image="$png" --button="Готово:0" \
          --text="Сфотографируйте этот экран и отправьте фото ${adminName}.

      $url"
      else
        yad --center --width=420 --title="Помощь" --button="OK:0" \
          --text="Нет интернета. Подключитесь к Wi-Fi (значок в углу экрана) и попробуйте снова."
      fi
    '';
  };

  boomerInstall = pkgs.writeShellApplication {
    name = "boomer-install";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
    ];
    text = ''
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

  boomerInstallGui = pkgs.writeShellApplication {
    name = "boomer-install-gui";
    runtimeInputs = with pkgs; [
      yad
      util-linux
      coreutils
      systemd
    ];
    text = ''
      src=$(readlink -f "$(findmnt -no SOURCE /iso)")
      parent=$(lsblk -ndo PKNAME "$src" || true)
      bootdisk=$src
      if [ -n "$parent" ]; then bootdisk=/dev/$parent; fi
      rows=()
      while read -r name size type rm model; do
        [ "$type" = disk ] && [ "$rm" = 0 ] && [ "$name" != "$bootdisk" ] || continue
        case "$name" in /dev/zram* | /dev/loop* | /dev/sr*) continue ;; esac
        rows+=("$name" "$size" "''${model:--}")
      done < <(lsblk -dnpo NAME,SIZE,TYPE,RM,MODEL)
      if [ ''${#rows[@]} -eq 0 ]; then
        yad --center --width=420 --title="Установка" --button="OK:0" \
          --text="Не найден подходящий диск. Позвоните ${adminName}."
        exit 1
      fi
      disk=$(yad --center --width=600 --height=300 --title="Установка системы" \
        --text="Выберите диск, на который установить систему:" \
        --list --column="Диск" --column="Размер" --column="Модель" \
        --print-column=1 --separator="" "''${rows[@]}") || exit 0
      [ -n "$disk" ] || exit 0
      yad --center --width=420 --title="Установка системы" \
        --button="Отмена:1" --button="Продолжить:0" \
        --text="Все файлы на диске $disk будут удалены. Продолжить?" || exit 0
      yad --center --width=420 --title="Установка системы" \
        --button="Отмена:1" --button="Да, удалить всё и установить:0" \
        --text="Вы уверены? Отменить это будет нельзя." || exit 0
      set +e
      /run/wrappers/bin/sudo ${boomerInstall}/bin/boomer-install "$disk" 2>&1 \
        | tee /tmp/boomer-install.log \
        | yad --center --width=450 --title="Установка системы" --progress --pulsate \
          --auto-close --no-buttons \
          --text="Идёт установка. Это займёт 10-30 минут. Не выключайте компьютер."
      status=''${PIPESTATUS[0]}
      set -e
      if [ "$status" -eq 0 ]; then
        yad --center --width=420 --title="Установка системы" --button="Перезагрузить:0" \
          --text="Готово! Выньте флешку и нажмите «Перезагрузить»." && systemctl reboot
      else
        yad --center --width=420 --title="Установка системы" --button="OK:0" \
          --text="Ошибка установки. Позвоните ${adminName}."
        exit 1
      fi
    '';
  };

  boomerWelcome = pkgs.writeShellApplication {
    name = "boomer-welcome";
    runtimeInputs = [ pkgs.yad ];
    text = ''
      choice=$(yad --center --width=450 --height=250 --title="Добро пожаловать" \
        --text="Что вы хотите сделать?" --list --no-headers --column="" \
        --print-column=1 --separator="" \
        "Помощь по интернету" "Установить систему на этот компьютер" "Просто посмотреть") || exit 0
      case "$choice" in
        "Помощь по интернету") exec ${boomerHelp}/bin/boomer-help ;;
        "Установить систему на этот компьютер") exec ${boomerInstallGui}/bin/boomer-install-gui ;;
      esac
    '';
  };

  helpItem = pkgs.makeDesktopItem {
    name = "boomer-help";
    desktopName = "Помощь по интернету";
    exec = "${boomerHelp}/bin/boomer-help";
    icon = "help-browser";
    categories = [ "System" ];
  };

  installItem = pkgs.makeDesktopItem {
    name = "boomer-install";
    desktopName = "Установить систему";
    exec = "${boomerInstallGui}/bin/boomer-install-gui";
    icon = "system-software-install";
    categories = [ "System" ];
  };

  welcomeItem = pkgs.makeDesktopItem {
    name = "boomer-welcome";
    desktopName = "Добро пожаловать";
    exec = "${boomerWelcome}/bin/boomer-welcome";
  };
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
        enable = isX11;
        xkb = {
          layout = keyboardLayouts;
          options = keyboardSwitch;
        };
        desktopManager.xfce = {
          enable = desktop == "xfce";
          enableScreensaver = false;
        };
        desktopManager.cinnamon.enable = desktop == "cinnamon";
      };
      services.desktopManager.plasma6.enable = isPlasma;
      services.displayManager.sddm = lib.mkIf isPlasma {
        enable = true;
        wayland.enable = true;
      };
      services.displayManager.autoLogin = {
        enable = true;
        inherit user;
      };

      programs.nm-applet.enable = desktop == "xfce";
      services.blueman.enable = isX11;
      programs.system-config-printer.enable = isX11;
      programs.thunar.plugins = lib.mkIf (desktop == "xfce") (
        with pkgs;
        [
          thunar-archive-plugin
          thunar-volman
        ]
      );

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
        preferences."intl.locale.requested" = "";
      };

      fonts.packages = with pkgs; [
        corefonts
        vista-fonts
        liberation_ttf
        noto-fonts
        noto-fonts-color-emoji
      ];

      environment.systemPackages =
        (with pkgs; [
          libreoffice
          hunspell
          hunspellDicts.ru_RU
          hunspellDicts.uk_UA
          hunspellDicts.en_US
          vlc
          simple-scan
          helpItem
        ])
        ++ lib.optionals isPlasma (
          with pkgs.kdePackages;
          [
            discover
            okular
            gwenview
            ark
            kcalc
            krfb
          ]
        )
        ++ lib.optionals isX11 (
          with pkgs;
          [
            gnome-software
            x11vnc
          ]
        )
        ++ lib.optionals (desktop == "xfce") (
          with pkgs;
          [
            atril
            galculator
            pavucontrol
            file-roller
            xfce4-pulseaudio-plugin
            xfce4-whiskermenu-plugin
          ]
        );

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
        extraSetFlags = [ "--operator=${user}" ];
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
      environment.systemPackages = [ installItem ];
      environment.etc."xdg/autostart/boomer-welcome.desktop".source =
        "${welcomeItem}/share/applications/boomer-welcome.desktop";
      security.sudo.extraRules = [
        {
          users = [ user ];
          commands = [
            {
              command = "${boomerInstall}/bin/boomer-install";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    })
  ];
}
