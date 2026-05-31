{
  xdg.configFile."Proton/VPN/settings.json".text = ''
    {
          "protocol": "wireguard",
          "killswitch": 1,
          "custom_dns": {
              "enabled": false,
              "ip_list": []
          },
          "ipv6": true,
          "anonymous_crash_reports": true,
          "features": {
              "netshield": 0,
              "moderate_nat": false,
              "vpn_accelerator": true,
              "port_forwarding": false,
              "split_tunneling": {
                  "enabled": false,
                  "mode": "exclude",
                  "config_by_mode": {
                      "exclude": {
                          "mode": "exclude",
                          "app_paths": [],
                          "ip_ranges": []
                      },
                      "include": {
                          "mode": "include",
                          "app_paths": [],
                          "ip_ranges": []
                      }
                  }
              }
          }
      }
  '';
}
