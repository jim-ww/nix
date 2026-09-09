{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.nixvim = import ./nixvim.nix { inherit pkgs lib config; };
}
