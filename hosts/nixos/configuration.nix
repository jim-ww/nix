{
  pkgs,
  config,
  ...
}:
{
  programs.sway.enable = true;

  programs.bash.blesh.enable = true;

  powerManagement.powertop.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  zramSwap.enable = true;

  services.getty = {
    autologinUser = config.user;
    autologinOnce = true;
  };

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  programs.dconf.enable = true;

  services.openssh.enable = true;
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  services.upower.enable = true;
  services.gvfs.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = config.packages;
  environment.variables = config.env;
  environment.sessionVariables.PATH = [ "${config.env.GOPATH}/bin" ];
  fonts.packages = config.font-packages;

  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  nix.settings = {
    warn-dirty = false;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.timeout = 2;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "24.05";
}
