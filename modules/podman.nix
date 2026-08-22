{ pkgs, config, ... }: {
  environment.variables.PODMAN_COMPOSE_PROVIDER = "docker-compose";

  # systemd.user.services.podman-api = {
  #   description = "Podman API Service";
  #   requires = ["podman.socket"];
  #   after = ["network.target" "podman.socket"];
  #   documentation = ["man:podman-system-service(1)"];
  #   startLimitIntervalSec = 0;
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = "${pkgs.podman}/bin/podman system service --time=0 unix://%t/podman/podman.sock";
  #     ExecStartPost = "${pkgs.podman}/bin/podman start --filter restart-policy=always --all";
  #     Environment = "PODMAN_SOCKET=%t/podman/podman.sock";
  #     KillMode = "process";
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #   };
  #   wantedBy = ["default.target"];
  # };

  systemd.user.sockets.podman = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
  };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = !config.virtualisation.docker.enable;
      dockerSocket.enable = !config.virtualisation.docker.enable;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  packages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    #podman-compose # start group of containers for dev
    podman-desktop
  ];
}
