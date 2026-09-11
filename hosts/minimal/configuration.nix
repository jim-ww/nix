{ pkgs, lib, ... }:
let
  user = "jim";
  hostname = "nixos";
  hashedPassword = "$y$j9T$k9cTxhpl3769v0w3vtHHC.$RMnePBGaEHYBg3IZDSnGry3TBScXMfDpPAGXlM9EOJA";
  initialRootHashPassword = hashedPassword;
  timezone = "Europe/Brussels";
  gitName = "jim-ww";
  gitEmail = "jim.w2610@proton.me";
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxGHWa43ZUlie9Tg6cxVkBFA41f2PSqniD3sn7TnDnK jim.w2610@proton.me"
  ];
  hardenedSSH = true;
in
{
  # hardware
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.libinput.touchpad.disableWhileTyping = true;
  services.tlp.enable = true;
  services.fstrim.enable = true;
  services.earlyoom.enable = true;
  systemd.oomd.enable = false;
  services.upower.enable = true;
  services.udisks2.enable = true;
  services.speechd.enable = false;
  zramSwap.enable = true;

  # networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;
    settings = lib.mkIf hardenedSSH {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
  };

  # session
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      noctalia
      foot
      wl-clipboard
      imv
      (mpv.override { youtubeSupport = false; })
      zathura
      keepassxc
      librewolf-bin
    ];
  };

  xdg.portal.extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-wlr ];

  environment.etc."sway/config.d/local.conf".text =
    let
      ipc = "noctalia msg";
    in
    ''
      input * {
        xkb_layout us,ru
        xkb_options grp:win_space_toggle
        xkb_numlock enabled
        tap enabled
        accel_profile flat
        pointer_accel 0.0
      }

      bindsym --no-warn $mod+q exec $term
      bindsym --no-warn $mod+c kill
      bindsym --no-warn $mod+e exec $term -e lf
      bindsym --no-warn $mod+d exec $term -e nvim
      bindsym --no-warn $mod+f exec librewolf
      bindsym --no-warn $mod+b exec keepassxc
      bindsym --no-warn $mod+v floating toggle
      bindsym --no-warn $mod+Shift+f fullscreen toggle
      bindsym --no-warn $mod+Tab exec ${ipc} panel-toggle control-center
      bindsym --no-warn $mod+p exec ${ipc} panel-toggle control-center audio
      bindsym --no-warn $mod+r exec ${ipc} panel-toggle launcher
      bindsym --no-warn $mod+Shift+a exec ${ipc} panel-toggle control-center system
      bindsym --no-warn $mod+k exec ${ipc} panel-toggle launcher '/calc '
      bindsym --no-warn $mod+w exec ${ipc} panel-toggle wallpaper
      bindsym --no-warn $mod+Shift+c exec ${ipc} panel-toggle clipboard
      bindsym --no-warn $mod+l exec ${ipc} session lock
      bindsym --no-warn --locked Alt+Tab exec ${ipc} window-switcher
      bindsym --no-warn Print exec ${ipc} screenshot-region
      bindsym --no-warn $mod+Print exec ${ipc} screenshot-fullscreen
      bindsym --no-warn $mod+F1 exec ${ipc} dpms-on
      bindsym --no-warn $mod+F2 exec ${ipc} dpms-off
      bindsym --no-warn --locked XF86AudioRaiseVolume exec ${ipc} volume-up
      bindsym --no-warn --locked XF86AudioLowerVolume exec ${ipc} volume-down
      bindsym --no-warn --locked XF86AudioMute exec ${ipc} volume-mute
      bindsym --no-warn --locked XF86AudioPlay exec ${ipc} media toggle
      bindsym --no-warn --locked XF86AudioPause exec ${ipc} media pause
      bindsym --no-warn --locked XF86AudioNext exec ${ipc} media next
      bindsym --no-warn --locked XF86AudioPrev exec ${ipc} media previous
      bindsym --no-warn --locked XF86MonBrightnessUp exec ${ipc} brightness-up 10
      bindsym --no-warn --locked XF86MonBrightnessDown exec ${ipc} brightness-down 10

      exec noctalia

      default_border pixel 1
      gaps inner 4
      smart_gaps on
    '';

  security.polkit.enable = true;
  programs.dconf.enable = true;

  services.getty = {
    autologinUser = lib.mkForce user;
    autologinOnce = false;
  };

  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && exec sway
  '';

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    noto-fonts-cjk-sans
  ];

  services.mpd = {
    enable = true;
    inherit user;
    settings.music_directory = "/home/${user}/Music";
  };
  systemd.services.mpd.environment.XDG_RUNTIME_DIR = "/run/user/1000";
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

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    configure.customLuaRC = ''
      vim.o.number = true
      vim.o.relativenumber = true
      vim.o.clipboard = "unnamedplus"
      vim.o.undofile = true
      vim.o.swapfile = false
      vim.opt.path:append("**")
      vim.o.ignorecase = true
      vim.o.smartcase = true
      vim.o.breakindent = true
      vim.o.linebreak = true
      vim.o.splitright = true
      vim.o.splitbelow = true
      vim.o.cursorline = true
      vim.o.scrolloff = 10
      vim.o.confirm = true
      vim.o.inccommand = "split"
      vim.o.list = true
      vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
      for _, k in ipairs({ "h", "j", "k", "l" }) do
        vim.keymap.set("n", "<C-" .. k .. ">", "<C-w><C-" .. k .. ">")
      end

      vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })
      vim.api.nvim_create_autocmd("BufReadPost", { command = [[silent! normal! g`"]] })
      vim.api.nvim_create_autocmd("BufWritePre", { callback = function(a) vim.fn.mkdir(vim.fn.fnamemodify(a.file, ":p:h"), "p") end })
    '';
  };

  # packages
  environment.systemPackages = with pkgs; [
    # cli
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
    pciutils
    usbutils

    # secrets & files
    age
    sops
    gnupg
    gocryptfs
    restic

    # net
    transmission_4
    wormhole-william
  ];

  # shell

  programs.bash.blesh.enable = true;

  environment.variables = {
    BROWSER = "librewolf";
    TERMINAL = "foot";
    LESS = "-R";
  };

  environment.shellAliases =
    let
      ls = "ls -h --group-directories-first --color=auto";
    in
    {
      v = "$EDITOR";
      c = "clear";
      l = ls;
      la = "${ls} -A";
      conf = "$EDITOR /etc/nixos/configuration.nix";
      ns = lib.getExe pkgs.nix-search-cli;
      nsp = "nix-shell -p";
      busybox = lib.getExe pkgs.busybox;
    };

  # users
  users.users.${user} = {
    isNormalUser = true;
    inherit hashedPassword;
    openssh.authorizedKeys.keys = authorizedKeys;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
  };

  users.users.root.initialHashedPassword = lib.mkForce initialRootHashPassword;
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

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
