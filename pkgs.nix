{ pkgs, ... }:
with pkgs;
[
  fd
  jq
  lf
  nh
  vim
  eza
  fzf
  imv
  mpv
  git
  age
  gtt # translator. C-J C-S Esc
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
  testdisk # disk recovery
  fastfetch
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
  imagemagick

  # music
  rmpc
  yt-dlp # or spotdl

  # gui
  keepassxc
  monero-gui
  pcmanfm
  element-desktop
  dino
  gnome-disk-utility
  localsend
  file-roller
  anki-bin
  lorien # infinite canvas

  ## dev
  go
  air
  tinygo
  gnumake
  gcc
  python3Minimal
  nodejs
  pnpm
  curlie
  sqlc
  tailwindcss_4
  protobuf
  protoc-gen-go
  protoc-gen-go-grpc
  grpcui
  lazydocker
  goose
  go-mockery
  ogen
  sqlite
  pgweb
  pocketbase
  hugo
  opentofu
  goreleaser
  cobra-cli
  gh
  devbox
  hyprpicker
  #kubectl
  codex # ai
]
