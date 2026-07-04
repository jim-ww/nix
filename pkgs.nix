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
  unrar #   unar
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
  groff
  (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe pkgs.groff} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'')

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
  imhex

  ## dev
  go
  air
  tinygo
  garble
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
  grpcurl
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
  ayugram-desktop
  csvq

  claude-code
  ungoogled-chromium
  wails
]
