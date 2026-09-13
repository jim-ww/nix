{
  programs.kage = {
    enable = true;
    systemd.enable = true;
    # settings = {
    #   storage.password_cmd = "cat /run/secrets/kage-key";
    # };
  };
}
