{
  device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/...",
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    disko
    nixos-anywhere
  ];

  fileSystems."/nix".neededForBoot = true;

  disko.devices.nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };
  };

  # luks-interactive-login + impermanence(preservation) + btrfs + swap
  disko.devices.disk.main = {
    inherit device;
    type = "disk";

    content.type = "gpt";

    content.partitions.boot = {
      name = "boot";
      size = "1M";
      type = "EF02";
    };

    content.partitions.ESP = {
      size = "500M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        #mountOptions = [ "umask=0077" ];
      };
    };

    content.partitions.root = {
      name = "root";
      size = "100%";
      content = {
        type = "luks";
        name = "crypt";
        settings.allowDiscards = true;
        passwordFile = "/tmp/secret.key"; # `echo -n "password" > /tmp/secret.key` (on target machine)
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];

          subvolumes = {
            "/persistent" = {
              mountOptions = [
                "subvol=persistent"
                "noatime"
                "compress=zstd"
              ];
              mountpoint = "/persistent";
            };

            "/nix" = {
              mountOptions = [
                "subvol=nix"
                "noatime"
                "compress=zstd"
              ];
              mountpoint = "/nix";
            };

            "/swap" = {
              mountpoint = "/swap";
              mountOptions = [
                "subvol=swap"
                "nodatacow"
                "noatime"
              ];
            };
          };
        };
      };
    };
  };
}
