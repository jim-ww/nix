{
  # Auto run transparent mode
  autoCmd = [
    {
      command = ":TransparentEnable";
      event = [ "VimEnter" ];
      pattern = [ "*" ];
    }
  ];

  plugins.transparent.enable = true;
}
