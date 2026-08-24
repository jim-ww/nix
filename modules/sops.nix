{ config, ... }: {
  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.keyFile = "/persistent/etc/sops/age/keys.txt";

  sops.secrets = {
    lastfm_password.owner = config.user;
    server1.owner = config.user;
    server2.owner = config.user;
    server-sig.owner = config.user;
    transmission-rpc-addr.owner = config.user;
    transmission-rpc-user.owner = config.user;
    transmission-rpc-pass.owner = config.user;
    ngrok-token.owner = config.user;
    ngrok-url.owner = config.user;
    gh-token = { };
    cloudflare-token = { };
    cloudflare-account-id = { };
    auth-payments-micro-priv-key = { };
    hcloud-token = { };
    oa-server.owner = config.user;
    oa-db-url = { };
    kage-key.owner = config.user;
    kage-acc1-passw.owner = config.user;
    kage-acc2-passw.owner = config.user;
    bookmarks.owner = config.user;
    xmr-daemon.owner = config.user;
    xmr-wallet.owner = config.user;
  };
}
