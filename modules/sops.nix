{ config, ... }:
{
  sops.defaultSopsFile = ../secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persistent/etc/sops/age/keys.txt";

  sops.secrets.lastfm_password.owner = config.user;
  sops.secrets.server1-url.owner = config.user;
}
