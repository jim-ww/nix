{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  gitUsername = "jim-ww";
  gitEmail = "jim.w2610@proton.me";
  home = "/home/${config.user}";
  documents = "${home}/Documents";

  gtkBookmarks = [
    "file://${home}/Archive"
    "file://${home}/Documents"
    "file://${home}/Projects"
    "file://${home}/Downloads"
    "file://${home}/Music"
  ];

  videosDir = "${home}/Videos";
  dataHome = "${home}/.local/share";
  stateHome = "${home}/.local/state";
  configHome = "${home}/.config";

  umountPersonal = "umount ~/Archive/personal";

  firejailCmd = extra:
    "firejail " + lib.concatStringsSep " " (config.firejailBaseArgs ++ extra) + " 2>/dev/null";
in {
  config = {
    user = "jim";
    shell = "bash";
    gitUsername = gitUsername;
    gitEmail = gitEmail;
    gpgKeyID = "84E78B81883125DEF4FFBD7735AE71B304C67013";
    packages = import ./pkgs.nix {inherit pkgs;};
    font-packages = with pkgs; [
      nerd-fonts.symbols-only # icons for terminal
      noto-fonts-cjk-sans # clean/readable japanese font
      # zpix-pixel-font # pixel japanese font
      # hachimarupop # cute japanese font
    ];
    firejailBaseArgs = [
      "--quiet"
      "--private=${home}/.private"
      "--private-tmp"
      "--private-dev"
      "--caps.drop=all"
      "--nonewprivs"
      "--noroot"
      "--nogroups"
      "--whitelist=/persistent${home}/.claude.json"
      "--whitelist=/persistent${home}/.claude"
      "--whitelist=/persistent${home}/.local/share/itpec-sensei"
      "--whitelist=/persistent${home}/.cache"
      "--whitelist=/persistent${home}/.private/.config/devin"
      "--whitelist=/persistent${home}/.private/.config/cursor"
      "--whitelist=/persistent${home}/.private/.local/share/devin"
      "--blacklist=/run/secrets"
      "--blacklist=${pkgs.tmux}/bin/tmux"
      "--blacklist=/run/user/$(id -u)/tmux-$(id -u)"
      "--whitelist=${home}/.private/"
      "--dbus-user=filter"
      "--dbus-user.talk=org.freedesktop.Notifications"
      "--dbus-user.talk=org.freedesktop.portal.Desktop"
      "--dbus-system=none"
      "--seccomp"
    ];

    wallpaper = {
      command = "swaybg -i $NH_FLAKE/wallpaper -m fill & disown";
      dir = "$NH_FLAKE/assets/wallpapers";
    };
    flakeDir = "${home}/Projects/nix";
    configHome = configHome;
    backupDir = "${home}/Archive/backups";
    musicDir = "/home/${config.user}/Music";
    term = "foot";
    editor = "nvim";
    file-manager = "pcmanfm";
    file-manager-term = "${config.term} ${lib.getExe pkgs.lf}";
    browser = "librewolf"; # "helium"; #"librewolf"; # "brave"; # "zen"; # "schizofox";
    duckduckgo = "https://duckduckgo.com/?kp=-2&kl=wt-wt&ka=Terminus&kt=Terminus&kj=1a1b26&kn=1&kx=a9b1d6&k1=-1&k5=2&k7=16161e&k8=a9b1d6&k9=7aa2f7&k18=1&kaa=bb9af7&kaf=s&kaj=m&kak=-1&kae=d&kao=-1&kap=-1&kaq=-1&kau=-1&kav=1&kax=-1&kay=b&kbf=1&duckai=1";
    bookmarks-menu = ''${lib.getExe pkgs.yq-go} -r '.[]' /run/secrets/bookmarks | ${lib.getExe pkgs.rofi} -dmenu -p 'search bookmarks...' | wl-copy '';
    music-player = "${config.term} rmpc --clean";
    passwords = "keepassxc ${documents}/.vault.kdbx";
    clipboard-manager = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";
    notesDir = documents;
    notes = "${config.term} -D ${config.notesDir} nvim notes.md";
    notes-all = "${config.term} -D ${config.notesDir} nvim .";
    app-menu = "${lib.getExe pkgs.rofi} -show drun";
    resource-monitor = "${config.term} btop";
    screenshot = ''${pkgs.busybox}/bin/sh -c 'geometry="$(${lib.getExe pkgs.slurp})" || exit 1; ${lib.getExe pkgs.grim} -g "$geometry" - | ${pkgs.busybox}/bin/tee ${home}/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png | ${pkgs.wl-clipboard}/bin/wl-copy' '';
    screenshot-full = "${pkgs.busybox}/bin/sh -c '${lib.getExe pkgs.grim} - | ${pkgs.busybox}/bin/tee ${home}/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png | ${pkgs.wl-clipboard}/bin/wl-copy' ";
    gtk.bookmarks = gtkBookmarks;
    swaylock = "${lib.getExe pkgs.swaylock} -efkli ${config.flakeDir}/wallpaper && ${umountPersonal}";
    env = {
      NH_FLAKE = config.flakeDir;
      REFINED_CHAR_SYMBOL = "ジ";
      TERM = config.term;
      EDITOR = "nvim";
      VISUAL = "nvim";
      LESS = "-R"; # syntax highlighting
      SHELL = config.shell;
      SOPS_AGE_KEY_FILE = "/persistent/etc/sops/age/keys.txt";

      DEFAULT_BROWSER = config.browser;
      BROWSER = config.browser;

      QT_QPA_PLATFORM = "wayland-egl";
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      QT_WAYLAND_FORCE_DPI = "physical";
      _JAVA_AWT_WM_NONREPARENTING = 1; # fix for some Java AWT applications (e.g. Android Studio)
      MOZ_ENABLE_WAYLAND = 1; # enable wayland support in Firefox
      XDG_SESSION_TYPE = "wayland";
      WLR_NO_HARDWARE_CURSORS = 1;
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland";
      NIXOS_OZONE_WL = "1";

      NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = 1;
      WRANGLER_SEND_METRICS = "false";
      WINEPREFIX = "~/Games/umu/umu-default";
      PROTONPATH = "${pkgs.proton-ge-bin.steamcompattool}";
      OLLAMA_NOHISTORY = 1;
      KAGE_DEBUG = "1";

      # Unclutter home dir
      GOPATH = "${dataHome}/go";
      GRADLE_USER_HOME = "${dataHome}/gradle";
      SONARLINT_USER_HOME = "${dataHome}/sonarlint";
      ELECTRUMDIR = "${dataHome}/electrum";
      UNISON = "${dataHome}/unison";
      RENPY_PATH_TO_SAVES = "${dataHome}";
      _ZL_DATA = "${dataHome}/zlua";
      PYTHONSTARTUP = "${home}/python/pythonrc";
      ANDROID_USER_HOME = "${dataHome}/android";
      DOCKER_CONFIG = "${configHome}/docker";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configHome}/java";
      PSQL_HISTORY = "${dataHome}/psql_history";

      LF_ICONS = ''
        di=:\
        fi=:\
        ln=:\
        or=:\
        ex=:\
        *.c=:\
        *.cc=:\
        *.clj=:\
        *.coffee=:\
        *.cpp=:\
        *.css=:\
        *.d=:\
        *.dart=:\
        *.erl=:\
        *.exs=:\
        *.fs=:\
        *.go=:\
        *.h=:\
        *.hh=:\
        *.hpp=:\
        *.hs=:\
        *.html=:\
        *.java=:\
        *.jl=:\
        *.js=:\
        *.json=:\
        *.lua=:\
        *.md=:\
        *.php=:\
        *.pl=:\
        *.pro=:\
        *.py=:\
        *.rb=:\
        *.rs=:\
        *.scala=:\
        *.ts=:\
        *.vim=:\
        *.cmd=:\
        *.ps1=:\
        *.sh=:\
        *.bash=:\
        *.zsh=:\
        *.fish=:\
        *.tar=:\
        *.tgz=:\
        *.arc=:\
        *.arj=:\
        *.taz=:\
        *.lha=:\
        *.lz4=:\
        *.lzh=:\
        *.lzma=:\
        *.tlz=:\
        *.txz=:\
        *.tzo=:\
        *.t7z=:\
        *.zip=:\
        *.z=:\
        *.dz=:\
        *.gz=:\
        *.lrz=:\
        *.lz=:\
        *.lzo=:\
        *.xz=:\
        *.zst=:\
        *.tzst=:\
        *.bz2=:\
        *.bz=:\
        *.tbz=:\
        *.tbz2=:\
        *.tz=:\
        *.deb=:\
        *.rpm=:\
        *.jar=:\
        *.war=:\
        *.ear=:\
        *.sar=:\
        *.rar=:\
        *.alz=:\
        *.ace=:\
        *.zoo=:\
        *.cpio=:\
        *.7z=:\
        *.rz=:\
        *.cab=:\
        *.wim=:\
        *.swm=:\
        *.dwm=:\
        *.esd=:\
        *.jpg=:\
        *.jpeg=:\
        *.mjpg=:\
        *.mjpeg=:\
        *.gif=:\
        *.bmp=:\
        *.pbm=:\
        *.pgm=:\
        *.ppm=:\
        *.tga=:\
        *.xbm=:\
        *.xpm=:\
        *.tif=:\
        *.tiff=:\
        *.png=:\
        *.svg=:\
        *.svgz=:\
        *.mng=:\
        *.pcx=:\
        *.mov=:\
        *.mpg=:\
        *.mpeg=:\
        *.m2v=:\
        *.mkv=:\
        *.webm=:\
        *.ogm=:\
        *.mp4=:\
        *.m4v=:\
        *.mp4v=:\
        *.vob=:\
        *.qt=:\
        *.nuv=:\
        *.wmv=:\
        *.asf=:\
        *.rm=:\
        *.rmvb=:\
        *.flc=:\
        *.avi=:\
        *.fli=:\
        *.flv=:\
        *.gl=:\
        *.dl=:\
        *.xcf=:\
        *.xwd=:\
        *.yuv=:\
        *.cgm=:\
        *.emf=:\
        *.ogv=:\
        *.ogx=:\
        *.aac=:\
        *.au=:\
        *.flac=:\
        *.m4a=:\
        *.mid=:\
        *.midi=:\
        *.mka=:\
        *.mp3=:\
        *.mpc=:\
        *.ogg=:\
        *.ra=:\
        *.wav=:\
        *.oga=:\
        *.opus=:\
        *.spx=:\
        *.xspf=:\
        *.pdf=:\
        *.nix=:
      '';
    };
    shellAliases = let
      ls = "${lib.getExe pkgs.eza}";
      fzf = "${lib.getExe pkgs.fzf}";
      term-editor = "$EDITOR";
    in {
      v = "$EDITOR";
      c = "clear";
      mv = "mv -v";
      cp = "cp -v";
      rm = "rm -v";
      cc = "cd ${config.flakeDir} && l";
      ccc = "cd ${config.flakeDir} && ${term-editor} $(${fzf})";
      l = ls;
      ls = ls;
      ll = "${ls} -l";
      la = "${ls} -a";
      lla = "${ls} -al";
      ff = "fastfetch -s title:separator:os:wm:lm:terminal:shell:packages:uptime:datetime:battery:disk:memory:theme:wmtheme:colors";
      conf = "cd ${config.flakeDir}/hosts/nixos && ${term-editor} configuration.nix";
      prefs = "cd ${config.flakeDir} && ${term-editor} prefs.nix";
      flake = "cd ${config.flakeDir} && ${term-editor} flake.nix";
      pkgs = "cd ${config.flakeDir} && ${term-editor} pkgs.nix";
      ns = "nix-search";
      nsp = "nix-shell --run ${config.shell} -p";
      nix-store-fix = "sudo nix-store --repair --verify --check-contents";

      gs = "git status";
      gc = "git commit";
      ga = "git add";
      gaa = "git add --all";
      gl = "git log";
      gr = "git remote";
      grl = "git reflog";
      gf = "git fetch";
      gi = "git init";
      gb = "git branch";
      gsw = "git switch";
      gd = "git diff";
      gcm = "git commit -m";
      gsm = "git stash -m";
      gwt = "git worktree";
      gcp = ''git commit -m "update" && git push'';
      gcl = "git clone";
      gco = "git checkout";
      gps = "git push";
      gpl = "git pull";

      ani = "ani-cli";
      umu = "umu-run";
      http = "curlie";
      "7z" = "7zz";
      transcribe-translate-jp = "whisperx --device cpu --model base --compute_type int8 --language ja --output_format srt --output_dir . --no_align --task translate";
      busybox = lib.getExe pkgs.busybox;
      set-wallpaper = config.wallpaper.command;
      set-video-wallper = ''mpvpaper  -vf "*" $NH_FLAKE/assets/video-wallpaper --mpv-options -o "--loop=yes" & disown'';
      nixos-anywhere-echo = "echo 'nixos-anywhere --flake $NH_FLAKE#nixos user@hostname -i ssh-key-path'";
      mpvsub = "mpv --sub-auto=fuzzy --audio-file-auto=fuzzy";
      jail = ''
        __jail() {
          if [ "$#" -gt 0 ]; then
            ${firejailCmd ["--private-cwd=${home}/work"]} bash -c "$*"
          else
            ${firejailCmd ["--private-cwd=${home}/work"]} bash -c 'exec bash -i'
          fi
        }; __jail'';

      jail-cwd = ''
        __jail_cwd() {
          local WORKDIR=/persistent$(pwd)
          local DIRNAME=$(basename "$(pwd)")
          local TMPSYMLINK=${home}/.private/$DIRNAME
          [ -L "$TMPSYMLINK" ] && rm "$TMPSYMLINK"
          ln -s "$WORKDIR" "$TMPSYMLINK"
          cd ~ || return
          if [ "$#" -gt 0 ]; then
            ${firejailCmd ["--whitelist=$WORKDIR"]} bash -c "cd ${home}/$DIRNAME; $*"
          else
            ${firejailCmd ["--whitelist=$WORKDIR"]} bash -c "cd ${home}/$DIRNAME; bash -i"
          fi
          cd - || return
          rm "$TMPSYMLINK"
        }; __jail_cwd'';
      wf-record = ''wf-recorder -a --audio-backend=pipewire --codec h264_vaapi --device /dev/dri/renderD128 -p preset=ultrafast -f "${videosDir}/rec_$(date +%d-%m-%Y-T%H-%M-%S).mkv"''; # preset=fast
      mount-personal = "mkdir -p ~/Archive/personal && gocryptfs ~/Archive/personal_enc ~/Archive/personal";
      umount-personal = umountPersonal;
      trcli = "transmission-cli";
      trcli-rmt = ''transmission-remote $(cat /run/secrets/transmission-rpc-addr) -n "$(cat /run/secrets/transmission-rpc-user):$(cat /run/secrets/transmission-rpc-pass)"'';
      wg-update-ip = ''sed -i "s/ip = \"[^\"]*\"/ip = \"$(wl-paste)\"/" $NH_FLAKE/modules/wireguard.nix'';
      wg-clear-ip = ''sed -i "s/ip = \"[^\"]*\"/ip = \"\"/" $NH_FLAKE/modules/wireguard.nix'';
      http-fs-serve = ''goeval 'log.Fatal(http.ListenAndServe(":8000", http.FileServer(http.Dir("."))))' '';
      yt-dlp = "yt-dlp --write-subs";
      itpec-sensei-mcp = "tmux new-session -s itpec-sensei-mcp 'NGROK_AUTHTOKEN=$(cat /run/secrets/ngrok-token) NGROK_RESERVED_URL=$(cat /run/secrets/ngrok-url) itpec-sensei serve --ngrok --remote'";
      bc = "busybox bc -q";
      gtr = "gtr -t ru";

      gomod2nix-init = "nix flake init -t github:nix-community/gomod2nix#app";

      # unclutter home dir
      wget = ''${lib.getExe pkgs.wget} --hsts-file="${dataHome}/wget-hsts"'';
      adb = ''HOME="${dataHome}"/android ${pkgs.android-tools}/bin/adb'';
      monerod = ''monerod --data-dir "${dataHome}"/bitmonero'';
    };
  };
  options = {
    user = mkOption {
      type = types.str;
    };
    shell = mkOption {
      type = types.str;
    };
    gitUsername = mkOption {
      type = types.str;
    };
    gitEmail = mkOption {
      type = types.str;
    };
    gpgKeyID = mkOption {
      type = types.str;
    };
    packages = mkOption {
      type = types.listOf types.package;
    };
    font-packages = mkOption {
      type = types.listOf types.package;
    };
    firejailBaseArgs = mkOption {
      type = types.listOf types.str;
    };
    wallpaper = {
      command = mkOption {
        type = types.str;
      };
      dir = mkOption {
        type = types.str;
      };
    };
    flakeDir = mkOption {
      type = types.str;
    };
    configHome = mkOption {
      type = types.str;
    };
    backupDir = mkOption {
      type = types.str;
    };
    musicDir = mkOption {
      type = types.str;
    };
    term = mkOption {
      type = types.str;
    };
    editor = mkOption {
      type = types.str;
    };
    file-manager = mkOption {
      type = types.str;
    };
    file-manager-term = mkOption {
      type = types.str;
    };
    browser = mkOption {
      type = types.str;
    };
    duckduckgo = mkOption {
      type = types.str;
    };
    bookmarks-menu = mkOption {
      type = types.str;
    };
    music-player = mkOption {
      type = types.str;
    };
    passwords = mkOption {
      type = types.str;
    };
    clipboard-manager = mkOption {
      type = types.str;
    };
    notesDir = mkOption {
      type = types.str;
    };
    notes = mkOption {
      type = types.str;
    };
    notes-all = mkOption {
      type = types.str;
    };
    app-menu = mkOption {
      type = types.str;
    };
    resource-monitor = mkOption {
      type = types.str;
    };
    screenshot = mkOption {
      type = types.str;
    };
    screenshot-full = mkOption {
      type = types.str;
    };
    gtk.bookmarks = mkOption {
      type = types.listOf types.str;
    };
    swaylock = mkOption {
      type = types.str;
    };
    env = mkOption {
      type = with types;
        lazyAttrsOf (oneOf [
          str
          path
          int
          float
        ]);
    };
    shellAliases = mkOption {
      type = types.attrsOf types.str;
    };
  };
}
