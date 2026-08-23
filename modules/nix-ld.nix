{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      gtk3
      pango
      cairo
      glib
      gdk-pixbuf
      atk
      harfbuzz
      stdenv.cc.cc.lib
      alsa-lib
      libpulseaudio
      openssl
      fontconfig
      libX11
      libXcursor
      libXinerama
      libXi
      libXrandr
      libXext
      libXfixes
      libxcb
      libxkbcommon
      wayland
      libdecor
      libGL
      libogg
      libvorbis
      libopus
      libpng
      libsm
      libice
      liberation_ttf
      freetype
    ];
  };
}
