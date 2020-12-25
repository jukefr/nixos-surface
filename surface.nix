{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      libinput = super.callPackage ./libinput-1.15.0.nix { };
      libwacom = super.callPackage ./surface-libwacom.nix { };
      surface-control = super.callPackage ./surface-control.nix { };
      surface_firmware = super.callPackage ./surface-firmware.nix { };
      surface_kernel = super.linuxPackages_4_19.extend (self: (ksuper: {
        kernel = ksuper.kernel.override {
          kernelPatches = [
            { patch = linux-surface/patches/4.19/0001-surface3-power.patch; name = "1"; }
            { patch = linux-surface/patches/4.19/0002-surface3-touchscreen-dma-fix.patch; name = "2"; }
            { patch = linux-surface/patches/4.19/0003-surface3-oemb.patch; name = "3"; }
            { patch = linux-surface/patches/4.19/0004-surface-buttons.patch; name = "4"; }
            { patch = linux-surface/patches/4.19/0005-suspend.patch; name = "5"; }
            { patch = linux-surface/patches/4.19/0006-ipts.patch; name = "6"; }
            { patch = linux-surface/patches/4.19/0007-wifi.patch; name = "7"; }
            { patch = linux-surface/patches/4.19/0008-surface-gpe.patch; name = "8"; }
            { patch = linux-surface/patches/4.19/0009-surface-sam-over-hid.patch; name = "9"; }
            { patch = linux-surface/patches/4.19/0010-surface-sam.patch; name = "10"; }
            { patch = linux-surface/patches/4.19/0011-surface-hotplug.patch; name = "11"; }
            { patch = linux-surface/patches/4.19/0012-surface-typecover.patch; name = "12"; }
            { patch = ./export_kernel_fpu_functions_4_14.patch; name = "13"; }
          ];
          extraConfig = ''
            INTEL_IPTS m
            INTEL_IPTS_SURFACE m
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
      kernelModules = [ "hid" "hid_sensor_hub" "i2c_hid" "hid_generic" "usbhid" "hid_multitouch" "intel_ipts" "surface_acpi" "zfs" ];
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];
  };

  services.udev.packages = [ pkgs.surface_firmware pkgs.libwacom ];

  services.xserver.videoDrivers = [ "intel" ];
  #services.xserver.videoDrivers = [ "nouveau" ];
  # bbswitch doesn't load
  # switcheroo doesn't work
  # nvidia-smi doesn't detect any hardware, it might only detect it with X
  # lshw -C display does detect the graphics card
  # X loads nvidia, then unloads it due to GLX error, this is maybe the best place to start
  #hardware.bumblebee = {
  #enable = true;
  #driver = "nvidia";
  #pmMethod = "bbswitch";
  #};

  #hardware.nvidiaOptimus.disable = true;
  #hardware.opengl.extraPackages = [ pkgs.linuxPackages.nvidia_x11.out ];
  #hardware.opengl.extraPackages32 = [ pkgs.linuxPackages.nvidia_x11.lib32 ];
  #hardware.nvidia = {
  #  modesetting.enable = true;
  #  optimus_prime = {
  #    enable = true;
  #    intelBusId = "PCI:0:2:0";
  #    nvidiaBusId = "PCI:2:0:0";
  #  };
  #};

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
