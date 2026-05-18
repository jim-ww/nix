{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = config.musicDir;
    dataDir = "${config.musicDir}/.mpd";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type          "pulse"
        name          "MPD (PipeWire)"
      }

      buffer_before_play "10%"
      connection_timeout "5"
    '';
  };

  services.mpdris2.enable = true;

  services.mpdscribble = {
    enable = true;
    endpoints."last.fm" = {
      username = "jim_www";
      passwordFile = "/run/secrets/lastfm_password";
    };
  };
}
