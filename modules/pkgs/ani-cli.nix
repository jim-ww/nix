{ pkgs, ... }:
pkgs.ani-cli.overrideAttrs (oldAttrs: {
  version = "allanime-fix";

  src = pkgs.fetchFromGitHub {
    owner = "justchokingaround";
    repo = "ani-cli";
    rev = "allanime-fix";
    hash = "sha256-OyCKDN89sBz59+3JncMDyNOq8UMqqjara+A0Owo3oko=";
  };
})
