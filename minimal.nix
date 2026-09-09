{ pkgs, lib, ... }:
let
  user = "jim";
  hashedPassword = "$y$j9T$k9cTxhpl3769v0w3vtHHC.$RMnePBGaEHYBg3IZDSnGry3TBScXMfDpPAGXlM9EOJA";
  timezone = "Europe/Brussels";
in
{
  # autologin
  services.getty = {
    autologinUser = user;
    autologinOnce = true;
  };
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  virtualisation.podman.enable = true;

  programs.bash.blesh.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };
  programs.dconf.enable = true; # ?

  services.openssh.enable = true;
  services.dbus.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;
  services.earlyoom.enable = true;
  services.earlyoom.enableNotifications = true;
  services.gnome.gnome-keyring.enable = true;
  services.tlp.enable = true;

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      mako &
      swayidle &
    '';
    extraPackages = with pkgs; [
      foot
      imv
      mpv
      grim
      mako
      rofi
      libnotify
      swaylock
      swayidle # ?
      wl-clipboard
      brightnessctl
      zathura
      keepassxc
      librewolf-bin
    ];
  };

  environment.systemPackages = with pkgs; [
    lf
    fzf
    neovim
    git
    _7zz
    btop
    ncdu
    tmux
    sops
    gnupg
    ripgrep
    tealdeer
    transmission_4
    # optional
    docker-compose
    wormhole-william
    gnumake
    fastfetch-unwrapped
    gocryptfs
    bluetuith
    trashy
    unison
    nix-search
    #steam-run-free
  ];

  environment.shellAliases = {
    v = "$EDITOR";
    c = "clear";
    conf = "$EDITOR /etc/nixos/configuration.nix";
    ns = "nix-search";
    nsp = "nix-shell -p";

    gs = "git status";
    ga = "git add";
    gaa = "git add --all";
    gl = "git log";
    gf = "git fetch";
    gi = "git init";
    gb = "git branch";
    gsw = "git switch";
    gd = "git diff";
    gcm = "git commit -m";
    gcl = "git clone";
    gps = "git push";
    gpl = "git pull";

    bc = "busybox bc -q";
    busybox = lib.getExe pkgs.busybox;
  };

  fonts.packages = [ pkgs.nerd-fonts.symbols-only ];

  environment.variables = {
    PODMAN_COMPOSE_PROVIDER = "docker-compose";
    TERMINAL = "foot";
    EDITOR = "nvim";
    LESS = "-R";
    BROWSER = "librewolf";
  };

  xdg.portal = {
    enable = true;
    config.common.default = [
      "wlr"
      "gtk"
    ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  nix.settings = {
    auto-optimise-store = true;
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

  users.users.${user} = {
    isNormalUser = true;
    hashedPassword = hashedPassword;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = timezone;
  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = false;
  services.pipewire.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  system.copySystemConfiguration = true;

  system.stateVersion = "24.05";
}
