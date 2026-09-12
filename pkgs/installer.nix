{
  lib,
  pkgs,
  name,
  target,
  usbOnly ? false,
  symlinkDevice ? false,
}:
let
  device = (builtins.head (builtins.attrValues target.disko.devices.disk)).device;
  luks = builtins.head (builtins.attrNames target.boot.initrd.luks.devices);
  labels = lib.filter (lib.hasPrefix "/dev/disk/by-partlabel/") (
    (map (fs: fs.device) (lib.attrValues target.fileSystems))
    ++ (map (d: d.device) (lib.attrValues target.boot.initrd.luks.devices))
  );
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    coreutils
    util-linux
    cryptsetup
    gawk
    nixos-install-tools
  ];
  text = ''
    parent() {
      lsblk -s -l -no TYPE,NAME "$1" | awk '$1=="disk"{print "/dev/"$2; exit}'
    }

    if [ $# -ne 1 ] || [ -z "$1" ]; then
      echo "usage: ${name} <disk>" >&2
      lsblk -dpo NAME,SIZE,TYPE,TRAN,MODEL >&2
      exit 1
    fi
    if [ "$(id -u)" -ne 0 ]; then
      echo "must run as root" >&2
      exit 1
    fi

    disk=$(readlink -f "$1")
    if [ ! -b "$disk" ] || [ "$(lsblk -dno TYPE "$disk")" != "disk" ]; then
      echo "not a whole disk: $1" >&2
      exit 1
    fi

    ${
      if symlinkDevice then
        ''
          ${lib.optionalString usbOnly ''
            if [ "$(lsblk -dno TRAN "$disk")" != "usb" ]; then
              echo "refusing $disk: ${name} only writes to usb disks" >&2
              exit 1
            fi
          ''}
          running=$(parent "$(findmnt -no SOURCE --nofsroot /nix)")
          if [ -n "$running" ] && [ "$(readlink -f "$running")" = "$disk" ]; then
            echo "refusing $disk: it backs the running system" >&2
            exit 1
          fi
        ''
      else
        ''
          if [ "$disk" != "$(readlink -f ${device})" ]; then
            echo "${name} installs to ${device}, refusing $1" >&2
            exit 1
          fi
        ''
    }

    mounted=$(lsblk -no MOUNTPOINTS "$disk" | grep -v '^[[:space:]]*$' || true)
    if [ -n "$mounted" ]; then
      echo "refusing $disk: something on it is mounted:" >&2
      echo "$mounted" >&2
      exit 1
    fi

    for label in ${lib.concatStringsSep " " labels}; do
      if [ -e "$label" ]; then
        owner=$(parent "$label")
        if [ "$(readlink -f "$owner")" != "$disk" ]; then
          echo "refusing $disk: $label already exists on $owner" >&2
          exit 1
        fi
      fi
    done

    lsblk -po NAME,SIZE,TYPE,TRAN,MODEL,SERIAL,MOUNTPOINTS "$disk" >&2
    read -rp "wipe $disk entirely? type 'wipe' to confirm: " confirm
    if [ "$confirm" != "wipe" ]; then
      echo "aborted" >&2
      exit 1
    fi

    read -rsp "LUKS passphrase: " pass1
    echo
    read -rsp "LUKS passphrase again: " pass2
    echo
    if [ "$pass1" != "$pass2" ] || [ -z "$pass1" ]; then
      echo "passphrases differ or are empty" >&2
      exit 1
    fi

    umask 022
    (umask 077; printf '%s' "$pass1" >/tmp/secret.key)
    ${lib.optionalString symlinkDevice ''ln -sfn "$disk" ${device}''}
    ${target.system.build.diskoScript} --yes-wipe-all-disks
    rm -f /tmp/secret.key
    nixos-install --root /mnt --system ${target.system.build.toplevel} \
      --no-root-passwd --no-channel-copy
    umount -R /mnt || true
    cryptsetup close ${luks} || true
  '';
}
