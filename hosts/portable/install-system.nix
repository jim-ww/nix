{
  lib,
  pkgs,
  installTarget,
  ...
}:
let
  target = installTarget;

  installSystem = import ../../pkgs/installer.nix {
    inherit lib pkgs target;
    name = "install-system";
  };
in
{
  system.extraDependencies = [
    target.system.build.toplevel
    target.system.build.diskoScript
  ];

  environment.systemPackages = [ installSystem ];
}
