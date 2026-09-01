{ pkgs, ... }:
with pkgs;
[
  # cli
  pv
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
  _7zz-rar

  imv
  # mpv
  ffmpeg
  imagemagick
  yt-dlp # or spotdl
  rmpc
  ani-cli
  anki

  git
  git-remote-gcrypt
  git-filter-repo
  gh
  bluetuith
  transmission_4
  wormhole-william # or croc
  nix-search-cli
  restic

  age
  sops
  openssl
  gocryptfs
  monero-cli

  groff
  (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe' pkgs.groff "groff"} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'')

  unison
  steam-run-free
  distrobox
  claude-code

  # gui
  keepassxc
  #anki
  umu-launcher

  # dev
  go
  gopls
  golint
  gcc
  gnumake
  python3Minimal
  pnpm
  curlie
  sqlite

  air
  sqlc
  tailwindcss_4
  goose
  pgweb
  pocketbase
  goreleaser
]
