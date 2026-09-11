{ config, ... }:
{
  sops.secrets.tailscale-admin = { };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-admin.path;
  };
}
