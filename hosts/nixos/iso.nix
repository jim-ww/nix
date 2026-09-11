{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  main = self.nixosConfigurations.nixos.config;
  target = main.disko.devices.disk.main.device;

  mainInstall = pkgs.writeShellApplication {
    name = "main-install";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
    ];
    text = ''
      if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "usage: main-install <disk> [age-key-file]" >&2
        echo "configured disk: ${target}" >&2
        lsblk -dpo NAME,SIZE,TYPE,MODEL >&2
        exit 1
      fi
      if [ "$(readlink -f "$1")" != "$(readlink -f ${target})" ]; then
        echo "disko is configured for ${target}, refusing to install to $1" >&2
        exit 1
      fi
      key=""
      if [ $# -eq 2 ]; then
        key=$(readlink -f "$2")
        if [ ! -f "$key" ]; then
          echo "age key not found: $2" >&2
          exit 1
        fi
      fi
      read -rsp "LUKS passphrase: " pass1
      echo
      read -rsp "LUKS passphrase again: " pass2
      echo
      if [ "$pass1" != "$pass2" ] || [ -z "$pass1" ]; then
        echo "passphrases differ or are empty" >&2
        exit 1
      fi
      umask 077
      printf '%s' "$pass1" >/tmp/secret.key
      ${main.system.build.diskoScript} --yes-wipe-all-disks
      rm -f /tmp/secret.key
      ${config.system.build.nixos-install}/bin/nixos-install --root /mnt \
        --system ${main.system.build.toplevel} \
        --no-root-passwd --no-channel-copy
      if [ -n "$key" ]; then
        install -D -m 0600 "$key" "/mnt${main.sops.age.keyFile}"
      else
        echo "no age key given: copy it to ${main.sops.age.keyFile} before sops secrets work" >&2
      fi
      umount -R /mnt || true
    '';
  };
in
{
  system.extraDependencies = [
    main.system.build.toplevel
    main.system.build.diskoScript
  ];
  environment.systemPackages = [ mainInstall ];
  services.getty.autologinUser = lib.mkForce config.user;
}
