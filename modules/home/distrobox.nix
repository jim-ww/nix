{
  programs.distrobox = {
    enable = true;
    containers = {
      arch = {
        # additional_packages = "git";
        entry = true;
        image = "archlinux:latest";
        init_hooks = [
          "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
          "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
        ];
      };
    };
    settings = {
      containers_always_pull = "0"; # 1
      container_user_custom_home = "$HOME/.local/share/distrobox";
      #container_manager = "docker";
      #non_interactive = "1";
      #container_image_default = "registry.opensuse.org/opensuse/toolbox:latest";
    };
  };
}
