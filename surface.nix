{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      libinput = super.callPackage ./libinput-1.16.4.nix { };
      libwacom = super.callPackage ./surface-libwacom.nix { };
      surface_firmware = super.callPackage ./surface-firmware.nix { };
      surface_kernel = super.linuxPackages_5_4.extend (self: (ksuper: {
        kernel = ksuper.kernel.override {
          kernelPatches = [
            { patch = ./linux-surface/patches/5.4/0001-surface3-power.patch; name = "1"; }
            { patch = ./linux-surface/patches/5.4/0002-surface3-oemb.patch; name = "2"; }
            { patch = ./linux-surface/patches/5.4/0003-wifi.patch; name = "3"; }
            { patch = ./linux-surface/patches/5.4/0004-ipts.patch; name = "4"; }
            { patch = ./linux-surface/patches/5.4/0005-surface-gpe.patch; name = "5"; }
            { patch = ./linux-surface/patches/5.4/0006-surface-sam-over-hid.patch; name = "6"; }
            { patch = ./linux-surface/patches/5.4/0007-surface-sam.patch; name = "7"; }
            { patch = ./linux-surface/patches/5.4/0008-surface-hotplug.patch; name = "8"; }
            { patch = ./linux-surface/patches/5.4/0009-surface-typecover.patch; name = "9"; }
            { patch = ./export_kernel_fpu_functions_5_3.patch; name = "10"; }
          ];
          extraConfig = ''
            SERIAL_DEV_BUS y
            SERIAL_DEV_CTRL_TTYPORT y
            INPUT_SOC_BUTTON_ARRAY m
            SURFACE_3_POWER_OPREGION m
            SURFACE_3_BUTTON m
            SURFACE_3_POWER_OPREGION m
            SURFACE_PRO3_BUTTON m
          '';
        };
      }));
    })
  ];

  environment.systemPackages = [ pkgs.libinput ];
  hardware.firmware = [ pkgs.surface_firmware ];

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = pkgs.surface_kernel;
    initrd = {
      kernelModules = [ "hid" "hid_sensor_hub" "i2c_hid" "hid_generic" "usbhid" "hid_multitouch" "ipts" "surface_acpi" ];
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    };
  };

  services.udev.packages = [ pkgs.surface_firmware pkgs.libwacom ];

  services.xserver.videoDrivers = [ "intel" ];
  powerManagement = {
    enable = true;
    #acpitool -W 2 >2 /dev/null
    powerUpCommands = ''
      source /etc/profile
      if ps cax | grep bluetoothd && ! bluetoothctl info; then
        bluetoothctl power off
      fi
    '';
    powerDownCommands = ''
      source /etc/profile
      modprobe -r ipts_surface
    '';
    resumeCommands = ''
      source /etc/profile
      if ps cax | grep bluetoothd; then
        bluetoothctl power on
      fi
      modprobe ipts_surface
    '';
  };

}
