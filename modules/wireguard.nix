{config, ...}: let
  serverPublicKey = "XvAXj8d5JYRNjaW32RZONkWlEoHgVPkzBLqosnZm6XM=";
  ip = "";
in {
  sops.secrets.wireguard-private-key = {};

  networking.firewall.allowedUDPPorts = [51820];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.252.1.2/32"];
      mtu = 1280;
      privateKeyFile = config.sops.secrets.wireguard-private-key.path;
      peers = [
        {
          publicKey = serverPublicKey;
          allowedIPs = ["10.252.1.1/32"];
          endpoint = "[${ip}]:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
