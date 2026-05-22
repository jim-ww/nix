{config, ...}: {
  sops.defaultSopsFile = ../secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persistent/etc/sops/age/keys.txt";

  sops.secrets.lastfm_password.owner = config.user;
  sops.secrets.server1-url.owner = config.user;
  sops.secrets.transmission-rpc-addr.owner = config.user;
  sops.secrets.transmission-rpc-user.owner = config.user;
  sops.secrets.transmission-rpc-pass.owner = config.user;
  sops.secrets.nom-cfg = {
    owner = config.user;
    path = "${config.configHome}/nom/config.yml";
  };
  sops.secrets.bookmarks.owner = config.user;
}
