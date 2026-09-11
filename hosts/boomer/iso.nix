{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  installed = self.nixosConfigurations.boomer.config;

  boomerInstall = pkgs.writeShellApplication {
    name = "boomer-install";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
    ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "usage: boomer-install <disk>" >&2
        lsblk -dpo NAME,SIZE,TYPE,MODEL >&2
        exit 1
      fi
      disk=$(readlink -f "$1")
      if [ ! -b "$disk" ]; then
        echo "not a block device: $1" >&2
        exit 1
      fi
      ln -sfn "$disk" /dev/boomer-disk
      ${installed.system.build.diskoScript} --yes-wipe-all-disks
      ${config.system.build.nixos-install}/bin/nixos-install --root /mnt \
        --system ${installed.system.build.toplevel} \
        --no-root-passwd --no-channel-copy
      umount -R /mnt || true
    '';
  };
in
{
  networking.hostName = lib.mkForce "${installed.networking.hostName}-usb";
  boot.loader.grub.enable = lib.mkForce false;
  users.users.root.initialHashedPassword = lib.mkForce null;
  services.openssh.openFirewall = lib.mkForce true;
  system.extraDependencies = [
    installed.system.build.toplevel
    installed.system.build.diskoScript
  ];
  environment.systemPackages = [ boomerInstall ];
}
