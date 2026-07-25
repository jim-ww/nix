{pkgs, ...}: let
  buildGoFromGitHub = {
    pname ? repo,
    owner,
    repo,
    rev,
    vendorHash ? null,
    githubHash ? null,
    useFetchGit ? false,
  } @ args:
    pkgs.buildGoModule {
      inherit pname vendorHash;
      version = builtins.substring 0 8 rev;
      src =
        if useFetchGit
        then
          builtins.fetchGit {
            url = "git@github.com:${owner}/${repo}.git";
            inherit rev;
          }
        else
          pkgs.fetchFromGitHub {
            inherit owner repo rev;
            hash = args.githubHash or pkgs.lib.fakeHash;
          };
    };
in
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
    fastfetch-unwrapped
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
    (pkgs.writeShellScriptBin "ms2pdf" ''${lib.getExe' pkgs.groff "groff"} -mms -Kutf8 -Tps "$1" | ${pkgs.ghostscript}/bin/ps2pdf - "$2"'')

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
    gopls
    golint
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
    cloudflared
    gh
    devbox
    graphviz # go prof
    ghz # grpc load test
    hyprpicker
    #kubectl
    ayugram-desktop
    csvq

    claude-code
    devin-cli
    cursor-cli
    # codex

    ungoogled-chromium
    wails
    godot # godot-mcp
    android-tools
    eid-mw

    (buildGoFromGitHub {
      owner = "mattn";
      repo = "nostr-relay";
      rev = "v0.0.246";
      githubHash = "sha256-6Y0Gwxmae1Py1eM3w9hSVk9Xc9yb6XB4V6CfIi1MWbQ=";
      vendorHash = "sha256-rM1cOGGrzZ9yNf+vscB5KHX+oiIULRAOt7T3rgDHRZg=";
    })

    postgresql
    (go-migrate.overrideAttrs (old: {
      tags = [
        "pgx5"
        "postgres"
      ];
    }))
  ]
