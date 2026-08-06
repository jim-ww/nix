{config, ...}: {
  programs.go = {
    enable = true;
    env.GOPATH = config.env.GOPATH;
    telemetry.mode = "on";
    # env.CGO_ENABLED = "0";
  };
}
