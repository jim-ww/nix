{ pkgs, config, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      webtorrent-mpv-hook
      thumbfast
      thumbfast-vanilla-osc
      autosub
      mpvacious # anki cards
      (pkgs.callPackage ./../../pkgs/animesubs-dl.nix { })

      mpris
      #webm
      #chapterskip

      # youtube:
      #sponsorblock
      #youtube-upnext
      #quality-menu

      # ui:
      # uosc
      # modernx
      # modernz
    ];
    config = {
      sub-auto = "fuzzy";
      sub-file-paths = "subs:${config.home.homeDirectory}/Videos/jpsubs";
      # log-file = "${config.home.homeDirectory}/mpv.log";
      slang = "jpn,jp,ja";
      osc = "no";
    };
    bindings = {
      "b" = "cycle-values sub-back-color \"#000000\" \"#00000000\"";
      "Ctrl+j" = "script-binding animeSubs_dl/auto_download_subs";
    };
  };

  home.file.".config/mpv/script-opts/thumbfast.conf".text = ''
    network=yes
  '';

  home.file.".config/mpv/script-opts/mpvacious.conf".text = ''
    host=127.0.0.1
    port=8765

    deck_name=mpvacious
    model_name=Japanese sentences

    sentence_field=SentKanji
    audio_field=SentAudio
    image_field=Image
  '';
}
