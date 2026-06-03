{pkgs, ...}:
with pkgs; [
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
  unar
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
  fastfetch.minimal
  gocryptfs
  openssl
  nix-search-cli
  file
  lsof
  tree
  bluetuith
  nixfmt
  nom
  ani-cli
  transmission_4
  imagemagick
  steam-run-free

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
  proton-vpn-cli
  tor-browser
  freetube

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
  graphviz # go prof
  ghz # grpc load test
  hyprpicker
  #kubectl
  codex # ai
]
