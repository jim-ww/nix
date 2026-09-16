{
  programs.rmpc = {
    enable = true;
    config = ''
      #![enable(implicit_some)]
      #![enable(unwrap_newtypes)]
      #![enable(unwrap_variant_newtypes)]
      (
          theme: "theme",
      )
    '';
  };

  xdg.configFile."rmpc/theme.ron".source = ./theme.ron;
}
