# Limine boot configuration for NixOS
{ config, pkgs, lib, ...}: {
  boot = {
    bootspec.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 20;
      };
    };
    tmp.cleanOnBoot = true;
    kernelPackages =
      pkgs.linuxPackages_latest; # _zen, _hardened, _rt, _rt_latest, etc.

    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;

    plymouth = {
       enable = true;
       theme = lib.mkForce "mac-style";
       themePackages = with pkgs; [ mac-style-plymouth ];
     };
  };

  # To avoid systemd services hanging on shutdown
  systemd.settings.Manager = { DefaultTimeoutStopSec = "10s"; };
}
