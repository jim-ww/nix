{
  description = "ani-cli bleeding-edge overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ani-cli-src = {
      url = "github:pystardust/ani-cli";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ani-cli-src,
  }:
    {
      overlays.default = final: prev: {
        ani-cli = final.stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "ani-cli";
          version = "unstable";
          src = ani-cli-src;

          nativeBuildInputs = with final; [makeWrapper];
          runtimeInputs = with final; [
            openssl
            gnugrep
            gnused
            curl
            fzf
            ffmpeg
            aria2
            botan3
          ];

          installPhase = ''
            runHook preInstall
            install -Dm755 ani-cli $out/bin/ani-cli
            wrapProgram $out/bin/ani-cli \
              --prefix PATH : ${final.lib.makeBinPath finalAttrs.runtimeInputs}
            runHook postInstall
          '';

          meta = with final.lib; {
            homepage = "https://github.com/pystardust/ani-cli";
            description = "Cli tool to browse and play anime";
            license = licenses.gpl3Plus;
            platforms = platforms.unix;
            mainProgram = "ani-cli";
          };
        });
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.ani-cli;
      }
    ));
}
