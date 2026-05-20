{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      53317 # localsend
    ];
    allowedUDPPorts = [
      57165 # barony
      47584 # payday2
    ];
  };
}
