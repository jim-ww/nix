{
  config,
  lib,
  ...
}:
with lib;
let
  home = "/home/${config.user}";
  dataHome = "${home}/.local/share";
  configHome = "${home}/.config";
in
{
  config = {
    env = {
      NH_FLAKE = config.flakeDir;
      REFINED_CHAR_SYMBOL = "ジ";
      TERM = "foot"; # terminfo name of the actual terminal; must stay literal, not the xdg-terminal-exec launcher
      EDITOR = config.editor;
      VISUAL = config.editor;
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
      OLLAMA_NOHISTORY = 1;
      KAGE_DEBUG = "1";

      SHARDIC_KEY_FILE = "/run/secrets/shardic-key";

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
        di=:\
        fi=:\
        ln=:\
        or=:\
        ex=:\
        *.c=:*.cc=:*.clj=:*.coffee=:*.cpp=:*.css=:*.d=:*.dart=:*.erl=:*.exs=:\
        *.fs=:*.go=:*.h=:*.hh=:*.hpp=:*.hs=:*.html=:*.java=:*.jl=:*.js=:\
        *.json=:*.lua=:*.php=:*.pl=:*.pro=:*.py=:*.rb=:*.rs=:*.scala=:*.ts=:\
        *.vim=:*.cmd=:*.ps1=:*.sh=:*.bash=:*.zsh=:*.fish=:\
        *.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:\
        *.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:\
        *.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:\
        *.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:\
        *.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:\
        *.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:\
        *.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:\
        *.pcx=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:\
        *.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:\
        *.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:\
        *.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.ogv=:*.ogx=:\
        *.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:\
        *.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:\
        *.md=:\
        *.pdf=:\
        *.nix=
      '';
    };
  };
  options = {
    env = mkOption {
      type =
        with types;
        lazyAttrsOf (oneOf [
          str
          path
          int
          float
        ]);
    };
  };
}
