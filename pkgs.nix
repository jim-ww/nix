{ pkgs, ... }:
with pkgs;
[
  # cli
  fd
  fzf
  jq
  lf
  gdu
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
  mpv
  ffmpeg
  yt-dlp # or spotdl
  rmpc
  ani-cli

  gitMinimal
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

  distrobox
  claude-code

  # gui
  keepassxc

  # dev
  go
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
  goreleaser
]
