{
  pkgs,
  lib,
  ...
}:
{
  # impermanence directory mount fix
  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce null;
  };
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    syncModels = true; # remove models not specified below
    loadModels = [
      "hf.co/bartowski/L3-8B-Stheno-v3.2-GGUF:Q4_K_M" # RP, load 15.2-15.4s | prefill 38.1 t/s | gen 5.42 t/s
      "hf.co/mradermacher/Huihui-Qwen3.5-9B-abliterated-GGUF:Q4_K_M" # general purpose, thinking
      "mannix/llama3.1-8b-abliterated" # general purpose, no thinking
      "fredrezones55/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:IQ2_M" # thinking, latest data cutoff
    ];
    environmentVariables = {
      OLLAMA_NUM_THREADS = "8";
      OLLAMA_VULKAN = "1";
      OLLAMA_IGPU_ENABLE = "1";
      OLLAMA_NO_CLOUD = "1";
      # OLLAMA_CLOUD_BASE_URL = "http://localhost:9080";
    };
  };
}
