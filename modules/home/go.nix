{config, ...}: {
  programs.go = {
    enable = true;
    env.GOPATH = config.env.GOPATH;
    env.CGO_ENABLED = "0";
    telemetry.mode = "on";
  };
}
