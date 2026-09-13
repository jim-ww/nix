{
  lib,
  pkgs,
  config,
  self,
  ...
}:
let
  main = self.nixosConfigurations.nixos.config;

  installSystem = import ../../pkgs/installer.nix {
    inherit lib pkgs;
    name = "install-system";
    target = main;
  };
in
{
  system.extraDependencies = [
    main.system.build.toplevel
    main.system.build.diskoScript
  ];
  environment.systemPackages = [ installSystem ];
  services.getty.autologinUser = lib.mkForce config.user;
}
