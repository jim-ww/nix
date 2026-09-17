{ ... }:
{
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:5300" ];

      dnscrypt_servers = true;
      doh_servers = false;
      odoh_servers = false;
      ipv6_servers = false;

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;

      lb_strategy = "random";

      anonymized_dns = {
        routes = [
          {
            server_name = "*";
            via = [ "*" ];
          }
        ];
        skip_incompatible = true;
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "127.0.0.1:5300" ];
      FallbackDNS = [ ];
      Domains = [ "~." ];
      DNSSEC = false;
    };
  };
}
