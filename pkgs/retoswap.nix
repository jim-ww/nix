{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
}: let
  version = "1.8.0";
  releaseTag = "v${version}-reto";
  mkSrc = system: hash: {
    url = "https://github.com/retoaccess1/haveno-reto/releases/download/${releaseTag}/haveno-v${version}-linux-${system}.AppImage";
    hash = hash;
  };
  srcs = {
    x86_64-linux = mkSrc "x86_64" "sha256-znLY75hNv2C6HMlxoB+65e0UfJvHK7opVl0pEYmhbUw=";
    aarch64-linux = mkSrc "aarch64" "sha256-at/ZMw1KeSLu8TBjaxoU5R9M6CnUGTuOZLHulHP6S3o=";
  };
  src = fetchurl srcs.${stdenv.hostPlatform.system};
  icon = fetchurl {
    url = "https://retoswap.com/images/webclip.png";
    hash = "sha256-Lp0nNKL/0EwjUxa7+YeezOCMQ5AFUaISibMOs5FxziY=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "haveno-reto";
      exec = "haveno-reto";
      icon = "haveno-reto";
      desktopName = "RetoSwap";
      categories = ["Finance" "Network"];
    })
  ];
in
  appimageTools.wrapType2 {
    pname = "haveno-reto";
    inherit version src desktopItems;

    nativeBuildInputs = [copyDesktopItems];

    extraInstallCommands = ''
      install -Dm444 ${icon} $out/share/icons/hicolor/256x256/apps/haveno-reto.png
    '';

    meta = {
      description = "P2P Monero decentralized exchange (DEX)";
      homepage = "https://retoswap.com";
      license = lib.licenses.agpl3Only;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      maintainers = [];
    };
  }
