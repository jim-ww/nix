{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  _module.args = {
    device = "/dev/portable-disk";
    diskName = "portable";
    luksName = "portable-crypt";
  };

  boot.tmp.cleanOnBoot = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    configurationLimit = 5;
  };
  boot.loader.timeout = 3;

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "uas"
    "usbhid"
    "hid_generic"
    "sd_mod"
    "sr_mod"
    "ahci"
    "nvme"
    "xhci_pci"
    "ehci_pci"
    "uhci_hcd"
    "ohci_pci"
    "sdhci_pci"
    "rtsx_pci_sdmmc"
  ];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable32Bit = true;

  services.thermald.enable = true;

  preservation.preserveAt."/state".files = [
    {
      file = "/etc/machine-id";
      inInitrd = true;
    }
  ];

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  services.journald.settings.Journal.Storage = "persistent";

  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_PART_ENTRY_NAME}=="disk-portable-root", RUN+="${pkgs.coreutils}/bin/ln -sfn /dev/$parent /dev/portable-disk"
  '';

  networking.hostName = "portable";

  services.tlp.enable = lib.mkForce false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
