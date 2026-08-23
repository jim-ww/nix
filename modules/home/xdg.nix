{
  pkgs,
  config,
  ...
}:
{
  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    publicShare = "${config.home.homeDirectory}/Downloads";
  };

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    config.common = {
      default = [
        "wlr"
        "gtk"
      ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "xdg-terminal-exec -- nvim %F";
    terminal = false;
    type = "Application";
    mimeType = [
      "text/plain"
      "text/markdown"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        editor = "nvim.desktop";
        code-editor = "nvim.desktop";
        fileManager = "${config.file-manager}.desktop";
        web-browser = "${config.browser}.desktop";
        video-player = "mpv.desktop";
        audio-player = "mpv.desktop";
        image-viewer = "imv-dir.desktop";
        document-viewer = "org.pwmt.zathura.desktop";
        archive-manager = "org.gnome.FileRoller.desktop";
      in
      {
        "inode/directory" = fileManager;

        "image/gif" = video-player;
        "image/jpeg" = image-viewer;
        "image/png" = image-viewer;
        "image/webp" = video-player;
        "image/svg+xml" = image-viewer;
        "image/avif" = image-viewer;

        "audio/mp3" = audio-player;
        "audio/mp4" = audio-player;
        "audio/flac" = audio-player;
        "audio/wav" = audio-player;
        "audio/ogg" = audio-player;
        "audio/x-flac" = audio-player;
        "audio/x-wav" = audio-player;
        "audio/x-vorbis+ogg" = audio-player;
        "audio/x-mpegurl" = audio-player;
        "audio/webm" = audio-player;

        "video/vnd.avi" = video-player;
        "video/x-matroska" = video-player;
        "video/mp4" = video-player;
        "video/webm" = video-player;

        "application/pdf" = document-viewer;
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "writer.desktop"
          document-viewer
        ];
        "application/epub+zip" = document-viewer;

        "text/plain" = editor;
        "text/markdown" = editor;
        "text/csv" = editor;
        "text/css" = [
          editor
          code-editor
        ];
        "text/html" = [
          web-browser
          code-editor
        ];
        "text/x-go" = code-editor;
        "text/x-python" = code-editor;
        "text/x-java" = code-editor;
        "text/javascript" = code-editor;
        "text/x-lua" = code-editor;
        "text/vnd.trolltech.linguist" = code-editor;

        "application/json" = editor;
        "application/yaml" = editor;
        "application/toml" = editor;
        "application/xml" = editor;
        "application/x-zerosize" = editor;
        "application/x-spss-sav" = editor;
        "application/octet-stream" = editor;
        "application/vnd.ms-publisher" = [
          "libreoffice-writer.desktop"
          editor
        ];
        "application/zip" = archive-manager;
        "application/sql" = [
          editor
          code-editor
        ];

        "x-scheme-handler/http" = web-browser;
        "x-scheme-handler/https" = web-browser;
        "x-scheme-handler/chrome" = web-browser;
        "x-scheme-handler/about" = web-browser;
        "x-scheme-handler/unknown" = web-browser;
        "x-scheme-handler/mailto" = web-browser;
        "application/x-extension-htm" = web-browser;
        "application/x-extension-html" = web-browser;
        "application/x-extension-shtml" = web-browser;
        "application/rdf+xml" = web-browser;
        "application/rss+xml" = web-browser;
        "application/xhtml+xml" = web-browser;
        "application/xhtml_xml" = web-browser;
        "application/x-extension-xht" = web-browser;
        "application/x-extension-xhtml" = web-browser;
        "application/x-partial-download" = video-player;

        "x-scheme-handler/freetube" = "freetube.desktop";
        "x-scheme-handler/tg" = [
          "com.ayugram.desktop.desktop"
          "org.telegram.desktop.desktop"
        ];
        "x-scheme-handler/tonsite" = [
          "com.ayugram.desktop.desktop"
          "org.telegram.desktop.desktop"
        ];
        "x-scheme-handler/viber" = "viber.desktop";
        "application/x-bittorrent" = "transmission.desktop"; # "transmission-gtk.desktop"

        "hoppscotch" = "hoppscotch-handler.desktop";
        "application/vnd.comicbook+zip" = [ document-viewer ];
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/sgnl" = "signal.desktop";
        "x-scheme-handler/signalcaptcha" = "signal.desktop";
      };
  };
}
