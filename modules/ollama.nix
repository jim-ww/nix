{
  pkgs,
  lib,
  ...
}: let
  cloudPolicy = pkgs.writeText "cloud_policy.go" ''
    //go:build linux

    package tools

    import "context"

    func ensureCloudEnabledForTool(ctx context.Context, operation string) error {
      println("ensureCloud called")
      return nil
    }
  '';
in {
  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce null;
  };
  services.ollama = {
    enable = true;
    loadModels = [
      "fredrezones55/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:IQ2_M"
      # "defyma85/gemma-4-E4B-it-ultra-uncensored-heretic-Q4_K_M_gguf"
    ];
  };
}
