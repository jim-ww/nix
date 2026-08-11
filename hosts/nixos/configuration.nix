{
  pkgs,
  config,
  ...
}: {
  programs.bash.blesh.enable = true;

  powerManagement.powertop.enable = true;

  programs.wshowkeys.enable = true;
  # security.wrappers.wshowkeys = {
  #   owner = "root";
  #   group = "root";
  #   source = "${pkgs.wshowkeys}/bin/wshowkeys";
  #   setuid = true;
  # };

  #services.pcscd.enable = true; # card reader

  # aarch64 emulation for cross-compiling
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  zramSwap.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  programs.firejail.enable = true;
  programs.dconf.enable = true;

  # TODO
  # services.vnstat.enable = true; # network usage
  services.openssh.enable = true;
  services.dbus = {
    enable = true;
    packages = [pkgs.dconf];
  };
  services.upower.enable = true;
  services.gvfs.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = config.packages;
  environment.variables = config.env;
  environment.sessionVariables.PATH = ["${config.env.GOPATH}/bin"];
  fonts.packages = config.font-packages;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    auto-optimise-store = true;
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
  #boot.supportedFilesystems = ["ntfs"];

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    "ru_RU.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  #system.copySystemConfiguration = true;

  system.stateVersion = "24.05";
}
