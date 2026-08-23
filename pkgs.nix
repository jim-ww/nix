{ pkgs, ... }:
with pkgs;
[
  fd
  jq
  lf
  nh
  vim
  fzf
  imv
  mpv
  git
  age
  _7zz
  ncdu
  sops
  btop
  tmux
  ripgrep
  ffmpeg
  tealdeer
  trashy
  unison
  fastfetch-unwrapped
  gocryptfs
  openssl
  nix-search-cli
  file
  lsof
  tree
  bluetuith
  nixfmt
  ani-cli
  transmission_4
  steam-run-free
  monero-cli
  groff
  (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe' pkgs.groff "groff"} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'')
  git-remote-gcrypt
  imagemagick
  rmpc
  git-filter-repo
  yt-dlp # or spotdl
  wormhole-william
  claude-code

  # gui
  keepassxc
  anki-bin
  proton-vpn-cli
  umu-launcher
  drawing
  file-roller
  pcmanfm

  ## dev
  go
  air
  gopls
  golint
  tinygo
  garble
  gnumake
  gcc
  curlie
  sqlc
  tailwindcss_4
  goose
  go-mockery
  sqlite
  pgweb
  pocketbase
  goreleaser
  cobra-cli
  gh
  wails3
  python3Minimal
  nodejs
  pnpm
]
