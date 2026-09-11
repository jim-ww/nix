{ lib, pkgs, ... }:
let
  keyFile = "/run/secrets/tailscale-boomer";
in
{
  nixpkgs.flake.setNixPath = false;
  services.tailscale.authKeyFile = lib.mkIf (!lib.inPureEvalMode && builtins.pathExists keyFile) (
    pkgs.writeText "tailscale-boomer" (lib.trim (builtins.readFile keyFile))
  );
}
