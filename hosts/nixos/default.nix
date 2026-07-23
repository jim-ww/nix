{
  imports = [
    ./hardware-config.nix
    ./configuration.nix
    ./disko.nix
    ./impermanence.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.wifi.powersave = true;
  services.libinput.touchpad.disableWhileTyping = true;
  #services.geoclue2.enable = true;

  _module.args.device = "/dev/nvme0n1";
}
