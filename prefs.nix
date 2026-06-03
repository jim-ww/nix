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

  dataHome = "${home}/.local/share";
  stateHome = "${home}/.local/state";
  configHome = "${home}/.config";

  umountPersonal = "umount ~/Archive/personal";
in {
  options = {
    user = mkOption {
      type = types.str;
      default = "jim";
    };
    shell = mkOption {
      type = types.str;
      default = "fish";
    };
    gitUsername = mkOption {
      type = types.str;
      default = gitUsername;
    };
    gitEmail = mkOption {
      type = types.str;
      default = gitEmail;
    };
    gpgKeyID = mkOption {
      type = types.str;
      default = "84E78B81883125DEF4FFBD7735AE71B304C67013";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = import ./pkgs.nix {inherit pkgs;};
    };
    font-packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        nerd-fonts.symbols-only # icons for terminal
        noto-fonts-cjk-sans # clean/readable japanese font
        # zpix-pixel-font # pixel japanese font
        # hachimarupop # cute japanese font
      ];
    };
    wallpaper = {
      command = mkOption {
        type = types.str;
        default = "swaybg -i $NH_FLAKE/wallpaper -m fill & disown";
      };
      dir = mkOption {
        type = types.str;
        default = "$NH_FLAKE/assets/wallpapers";
      };
    };
    flakeDir = mkOption {
      type = types.str;
      default = "${home}/Projects/nix";
    };
    configHome = mkOption {
      type = types.str;
      default = configHome;
    };
    backupDir = mkOption {
      type = types.str;
      default = "${home}/Archive/backups";
    };
    musicDir = mkOption {
      type = types.str;
      default = "/home/${config.user}/Music";
    };
    term = mkOption {
      type = types.str;
      default = "foot";
    };
    editor = mkOption {
      type = types.str;
      default = "nvim";
    };
    file-manager = mkOption {
      type = types.str;
      default = "pcmanfm";
    };
    file-manager-term = mkOption {
      type = types.str;
      default = "${config.term} ${lib.getExe pkgs.lf}";
    };
    browser = mkOption {
      type = types.str;
      default = "librewolf"; # "helium"; #"librewolf"; # "brave"; # "zen"; # "schizofox";
    };
    duckduckgo = mkOption {
      type = types.str;
      default = "https://duckduckgo.com/?kp=-2&kl=wt-wt&ka=Terminus&kt=Terminus&kj=1a1b26&kn=1&kx=a9b1d6&k1=-1&k5=2&k7=16161e&k8=a9b1d6&k9=7aa2f7&k18=1&kaa=bb9af7&kaf=s&kaj=m&kak=-1&kae=d&kao=-1&kap=-1&kaq=-1&kau=-1&kav=1&kax=-1&kay=b&kbf=1&duckai=1";
    };
    bookmarks-menu = mkOption {
      type = types.str;
      default = ''${lib.getExe pkgs.yq-go} -r '.[]' /run/secrets/bookmarks | ${lib.getExe pkgs.rofi} -dmenu -p 'search bookmarks...' | wl-copy '';
    };
    music-player = mkOption {
      type = types.str;
      default = "${config.term} rmpc";
    };
    passwords = mkOption {
      type = types.str;
      default = "keepassxc ${documents}/.vault.kdbx";
    };
    clipboard-manager = mkOption {
      type = types.str;
      default = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";
    };
    notesDir = mkOption {
      type = types.str;
      default = documents;
    };
    notes = mkOption {
      type = types.str;
      default = "${config.term} -D ${config.notesDir} vim notes.md";
    };
    notes-all = mkOption {
      type = types.str;
      default = "${config.term} -D ${config.notesDir} vim .";
    };
    app-menu = mkOption {
      type = types.str;
      default = "${lib.getExe pkgs.rofi} -show drun";
    };
    resource-monitor = mkOption {
      type = types.str;
      default = "${config.term} btop";
    };
    screenshot = mkOption {
      type = types.str;
      default = ''${pkgs.busybox}/bin/sh -c 'geometry="$(${lib.getExe pkgs.slurp})" || exit 1; ${lib.getExe pkgs.grim} -g "$geometry" - | ${pkgs.busybox}/bin/tee ${home}/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png | ${pkgs.wl-clipboard}/bin/wl-copy' '';
    };
    screenshot-full = mkOption {
      type = types.str;
      default = "${pkgs.busybox}/bin/sh -c '${lib.getExe pkgs.grim} - | ${pkgs.busybox}/bin/tee ${home}/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png | ${pkgs.wl-clipboard}/bin/wl-copy' ";
    };
    gtk.bookmarks = mkOption {
      type = types.listOf types.str;
      default = gtkBookmarks;
    };
    swaylock = mkOption {
      type = types.str;
      default = "${lib.getExe pkgs.swaylock} -efkli ${config.flakeDir}/wallpaper && ${umountPersonal}";
    };
    env = mkOption {
      type = with types;
        lazyAttrsOf (oneOf [
          str
          path
          int
          float
        ]);
      default = {
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
        WINEPREFIX = "~/Games/umu/umu-default";
        WRANGLER_SEND_METRICS = "false";

        # Unclutter home dir
        GOPATH = "${dataHome}/go";
        HISTFILE = "${stateHome}/bash/history";
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
          di=:\
          fi=:\
          ln=:\
          or=:\
          ex=:\
          *.c=:\
          *.cc=:\
          *.clj=:\
          *.coffee=:\
          *.cpp=:\
          *.css=:\
          *.d=:\
          *.dart=:\
          *.erl=:\
          *.exs=:\
          *.fs=:\
          *.go=:\
          *.h=:\
          *.hh=:\
          *.hpp=:\
          *.hs=:\
          *.html=:\
          *.java=:\
          *.jl=:\
          *.js=:\
          *.json=:\
          *.lua=:\
          *.md=:\
          *.php=:\
          *.pl=:\
          *.pro=:\
          *.py=:\
          *.rb=:\
          *.rs=:\
          *.scala=:\
          *.ts=:\
          *.vim=:\
          *.cmd=:\
          *.ps1=:\
          *.sh=:\
          *.bash=:\
          *.zsh=:\
          *.fish=:\
          *.tar=:\
          *.tgz=:\
          *.arc=:\
          *.arj=:\
          *.taz=:\
          *.lha=:\
          *.lz4=:\
          *.lzh=:\
          *.lzma=:\
          *.tlz=:\
          *.txz=:\
          *.tzo=:\
          *.t7z=:\
          *.zip=:\
          *.z=:\
          *.dz=:\
          *.gz=:\
          *.lrz=:\
          *.lz=:\
          *.lzo=:\
          *.xz=:\
          *.zst=:\
          *.tzst=:\
          *.bz2=:\
          *.bz=:\
          *.tbz=:\
          *.tbz2=:\
          *.tz=:\
          *.deb=:\
          *.rpm=:\
          *.jar=:\
          *.war=:\
          *.ear=:\
          *.sar=:\
          *.rar=:\
          *.alz=:\
          *.ace=:\
          *.zoo=:\
          *.cpio=:\
          *.7z=:\
          *.rz=:\
          *.cab=:\
          *.wim=:\
          *.swm=:\
          *.dwm=:\
          *.esd=:\
          *.jpg=:\
          *.jpeg=:\
          *.mjpg=:\
          *.mjpeg=:\
          *.gif=:\
          *.bmp=:\
          *.pbm=:\
          *.pgm=:\
          *.ppm=:\
          *.tga=:\
          *.xbm=:\
          *.xpm=:\
          *.tif=:\
          *.tiff=:\
          *.png=:\
          *.svg=:\
          *.svgz=:\
          *.mng=:\
          *.pcx=:\
          *.mov=:\
          *.mpg=:\
          *.mpeg=:\
          *.m2v=:\
          *.mkv=:\
          *.webm=:\
          *.ogm=:\
          *.mp4=:\
          *.m4v=:\
          *.mp4v=:\
          *.vob=:\
          *.qt=:\
          *.nuv=:\
          *.wmv=:\
          *.asf=:\
          *.rm=:\
          *.rmvb=:\
          *.flc=:\
          *.avi=:\
          *.fli=:\
          *.flv=:\
          *.gl=:\
          *.dl=:\
          *.xcf=:\
          *.xwd=:\
          *.yuv=:\
          *.cgm=:\
          *.emf=:\
          *.ogv=:\
          *.ogx=:\
          *.aac=:\
          *.au=:\
          *.flac=:\
          *.m4a=:\
          *.mid=:\
          *.midi=:\
          *.mka=:\
          *.mp3=:\
          *.mpc=:\
          *.ogg=:\
          *.ra=:\
          *.wav=:\
          *.oga=:\
          *.opus=:\
          *.spx=:\
          *.xspf=:\
          *.pdf=:\
          *.nix=:
        '';
      };
    };
    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = let
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
        conf = "cd ${config.flakeDir} && ${term-editor} configuration.nix";
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
        gtt = "gtt --src=English -dst=Russian";
        firejail-enter = "firejail --private=. --seccomp ${config.shell}";
        wf-record = ''wf-recorder -a --audio-backend=pipewire --codec h264_vaapi --device /dev/dri/renderD128 -p preset=fast -f "$XDG_VIDEOS_DIR/rec_$(date +%d-%m-%Y-T%H-%M-%S).mkv"'';
        mount-personal = "mkdir -p ~/Archive/personal && gocryptfs ~/Archive/personal_enc ~/Archive/personal";
        umount-personal = umountPersonal;
        trcli = "transmission-cli";
        trcli-rmt = ''transmission-remote $(cat /run/secrets/transmission-rpc-addr) -n "$(cat /run/secrets/transmission-rpc-user):$(cat /run/secrets/transmission-rpc-pass)"'';

        gomod2nix-init = "nix flake init -t github:nix-community/gomod2nix#app";

        # unclutter home dir
        wget = ''wget --hsts-file="${dataHome}/wget-hsts"'';
        adb = ''HOME="${dataHome}"/android adb'';
        monerod = ''monerod --data-dir "${dataHome}"/bitmonero'';
      };
    };
  };
}
