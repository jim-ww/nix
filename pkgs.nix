{ pkgs, ... }:
with pkgs;
[
  # cli
  fd
  fzf
  jq
  lf
  ncdu
  tree
  file
  lsof
  tealdeer
  fastfetch-unwrapped
  nixfmt
  nh
  vim
  btop
  tmux
  ripgrep
  _7zz

  imv
  mpv
  ffmpeg
  imagemagick
  yt-dlp # or spotdl
  rmpc
  ani-cli

  git
  git-remote-gcrypt
  git-filter-repo
  gh
  bluetuith
  transmission_4
  wormhole-william # or croc
  nix-search-cli

  age
  sops
  openssl
  gocryptfs
  monero-cli

  groff
  (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe' pkgs.groff "groff"} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'')

  unison
  steam-run-free
  claude-code

  # gui
  keepassxc
  #anki
  umu-launcher
  drawing
  file-roller
  nautilus

  # dev
  go
  gopls
  golint
  gcc
  gnumake
  python3Minimal
  nodejs
  pnpm
  curlie
  sqlite

  air
  tinygo
  garble
  sqlc
  ogen
  tailwindcss_4
  goose
  go-mockery
  pgweb
  pocketbase
  goreleaser
  cobra-cli
  wails3
]
