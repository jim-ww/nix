{ pkgs, config, ... }: {
  environment.variables.PODMAN_COMPOSE_PROVIDER = "docker-compose";

  environment.etc.timezone.text = config.time.timeZone;

  virtualisation.podman = {
    enable = true;
    dockerCompat = !config.virtualisation.docker.enable;
    dockerSocket.enable = !config.virtualisation.docker.enable;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-tui
    docker-compose
  ];
}
