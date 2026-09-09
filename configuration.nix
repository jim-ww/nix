{
  pkgs,
  config,
  ...
}:
{
  # programs.wshowkeys.enable = true;

  programs.dconf.enable = true;
  programs.gamemode.enable = true;

  security.polkit.enable = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  services.libinput.touchpad.disableWhileTyping = true;

  services.getty = {
    autologinUser = config.user;
    autologinOnce = true;
  };

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  services.openssh.enable = true;
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  services.earlyoom.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true; # also pulls in udisks2
  services.fstrim.enable = true;

  environment.systemPackages = config.packages;
  environment.variables = config.env;
  environment.sessionVariables.PATH = [ "${config.env.GOPATH}/bin" ];
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only # icons for terminal
    noto-fonts-cjk-sans # clean/readable japanese font
  ];

  nixpkgs.config.allowUnfree = true;

  powerManagement.powertop.enable = true;
  zramSwap.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.graphics.enable = true;

  system.stateVersion = "24.05";
}
