{
  pkgs,
  config,
  lib,
  ...
}: {
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  environment.systemPackages = [pkgs.wl-clipboard];

  preservation.preserveAt."/persistent" = {
    directories = [
      "/var/lib/waydroid"
    ];
    users."${config.user}".directories = [
      ".local/share/waydroid/"
    ];
  };

  firejailBaseArgs = lib.mkAfter [
    "--whitelist=/persistent/var/lib/waydroid"
    "--dbus-system.talk=id.waydro.Container"
  ];
}
