{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.splashImage = null;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.availableKernelModules = ["uhci_hcd" "xhci_pci" "ehci_pci" "ata_piix" "ahci" "sd_mod" "sr_mod"];

  networking.interfaces.enp0s5.useDHCP = true;

  services.mingetty.autologinUser = "dottedmag";
}
