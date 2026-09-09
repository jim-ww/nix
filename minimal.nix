{ pkgs, lib, ... }:
let
  user = "jim";
  hashedPassword = "$y$j9T$k9cTxhpl3769v0w3vtHHC.$RMnePBGaEHYBg3IZDSnGry3TBScXMfDpPAGXlM9EOJA";
  timezone = "Europe/Brussels";
  term = "foot";
  editor = "nvim";
  browser = "librewolf";
  gitName = "jim-ww";
  gitEmail = "jim.w2610@proton.me";
in
{
  # TODO: dbus, neovim, upower, gvfs

  # hardware

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.libinput.touchpad.disableWhileTyping = true;
  services.tlp.enable = true;
  services.fstrim.enable = true;
  services.earlyoom.enable = true;
  zramSwap.enable = true;

  # networking

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh.enable = true;

  # audio

  services.pipewire = {
    enable = true;
    alsa.enable = true;
  };

  # session
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      foot
      rofi
      mako
      swaylock
      swayidle
      grim
      wl-clipboard
      brightnessctl
      libnotify
      imv
      mpv
      zathura
      keepassxc # TODO
      librewolf-bin
    ];
  };

  environment.etc."sway/config.d/local.conf".text = ''
    set $menu rofi -show drun

    input * {
      xkb_layout us,ru
      xkb_options grp:win_space_toggle
      xkb_numlock enabled
      tap enabled
      accel_profile flat
      pointer_accel 0.0
    }

    bindsym $mod+q exec $term
    bindsym $mod+c kill
    bindsym $mod+e exec $term -e lf
    bindsym $mod+d exec $term -e nvim
    bindsym $mod+f exec librewolf
    bindsym $mod+b exec keepassxc
    bindsym $mod+r exec $menu
    bindsym $mod+v floating toggle
    bindsym $mod+l exec swaylock -efkl
    bindsym $mod+Shift+f fullscreen toggle
    bindsym Print exec grim - | wl-copy

    exec mako
    exec swayidle -w timeout 600 'swaylock -efkl' before-sleep 'swaylock -efkl'

    default_border pixel 1
    gaps inner 4
    smart_gaps on
  '';

  security.polkit.enable = true;
  security.pam.services.swaylock = { };
  programs.dconf.enable = true;

  services.getty = {
    autologinUser = lib.mkForce user;
    autologinOnce = false;
  };

  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && exec sway
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    noto-fonts-cjk-sans
  ];

  services.mpd.enable = true;
  services.mpd.settings.music_directory = "$HOME/Music";

  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      user.name = gitName;
      user.email = gitEmail;
    };
  };

  # packages

  environment.systemPackages = with pkgs; [
    # cli
    neovim
    nh
    fd
    lf
    fzf
    ripgrep
    tmux
    btop
    file
    tree
    gdu
    wget
    curl
    _7zz-rar
    rsync
    tealdeer
    fastfetch-unwrapped
    jujutsu
    steam-run-free
    ffmpeg-headless
    monero-cli
    (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe' pkgs.groff "groff"} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'') # usage: ms2pdf <input.ms> <output.pdf>

    # disks
    parted
    gptfdisk
    cryptsetup
    btrfs-progs
    dosfstools
    e2fsprogs
    testdisk

    # secrets & files
    age
    sops
    gnupg
    gocryptfs
    restic

    # net
    bluetuith
    transmission_4
    wormhole-william
  ];

  # shell

  programs.bash.blesh.enable = true;

  environment.variables = {
    EDITOR = editor;
    VISUAL = editor;
    BROWSER = browser;
    TERMINAL = term;
    LESS = "-R";
  };

  environment.shellAliases = {
    v = "$EDITOR";
    c = "clear";
    l = "ls -h --group-directories-first --color=auto";
    la = "ls -hA --group-directories-first --color=auto";
    conf = "$EDITOR /etc/nixos/configuration.nix";
    ns = lib.getExe pkgs.nix-search-cli;
    nsp = "nix-shell -p";
  };

  # users

  users.users.${user} = {
    isNormalUser = true;
    inherit hashedPassword;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  # nix

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
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

  # locale

  time.timeZone = timezone;
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "24.05";
}
