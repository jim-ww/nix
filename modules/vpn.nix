{ config, pkgs, ... }:
{
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  sops.secrets.vpn.path = "/run/secrets/vpn.conf";

  systemd.services.vpn = {
    description = "WireGuard VPN tunnel";
    after = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    wants = [ "network-online.target" ];
    # wantedBy = [ "multi-user.target" ];
    path = [ pkgs.wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up ${config.sops.secrets.vpn.path}";
      ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down ${config.sops.secrets.vpn.path}";
    };
  };
}
