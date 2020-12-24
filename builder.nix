{config, lib, pkgs, ... }:
{ 
  nixpkgs.overlays = [(self: super: {
    libinput = super.callPackage ./libinput-1.15.0.nix {};
    libwacom = super.callPackage ./surface-libwacom.nix {};
    surface-control = super.callPackage ./surface-control.nix {};
    surface_firmware = super.callPackage ./surface-firmware.nix {};
    surface_kernel = super.linuxPackages_4_19.extend( self: (ksuper: {
      kernel = ksuper.kernel.override {
        kernelPatches = [
          { patch = linux-surface/patches/4.19/0001-surface3-power.patch; name = "1"; }
          { patch = linux-surface/patches/4.19/0002-surface3-spi.patch; name = "2"; }
          { patch = linux-surface/patches/4.19/0003-surface3-oemb.patch; name = "3"; }
          { patch = linux-surface/patches/4.19/0004-surface-buttons.patch; name = "4"; }
          { patch = linux-surface/patches/4.19/0005-surface-sam.patch; name = "5"; }
          { patch = linux-surface/patches/4.19/0006-suspend.patch; name = "6"; }
          { patch = linux-surface/patches/4.19/0007-ipts.patch; name = "7"; }
          { patch = linux-surface/patches/4.19/0008-surface-lte.patch; name = "8"; }
          { patch = linux-surface/patches/4.19/0009-ioremap_uc.patch; name = "9"; }
          { patch = linux-surface/patches/4.19/0010-wifi.patch; name = "10"; }
          { patch = ./export_kernel_fpu_functions_4_14.patch; name = "11"; }
        ];
        extraConfig = ''
          INTEL_IPTS m
          INTEL_IPTS_SURFACE m
          SERIAL_DEV_BUS y
          SERIAL_DEV_CTRL_TTYPORT y
          SURFACE_SAM m
          SURFACE_SAM_SSH m
          SURFACE_SAM_SSH_DEBUG_DEVICE y
          SURFACE_SAM_SAN m
          SURFACE_SAM_VHF m
          SURFACE_SAM_DTX m
          SURFACE_SAM_HPS m
          SURFACE_SAM_SID m
          SURFACE_SAM_SID_GPELID m
          SURFACE_SAM_SID_PERFMODE m
          SURFACE_SAM_SID_VHF m
          SURFACE_SAM_SID_POWER m
          INPUT_SOC_BUTTON_ARRAY m
          SURFACE_3_POWER_OPREGION m
          SURFACE_3_BUTTON m
          SURFACE_3_POWER_OPREGION m
          SURFACE_PRO3_BUTTON m
        '';
      };
    }));
  })];

  environment.systemPackages = [
    pkgs.libinput
    pkgs.libwacom
    pkgs.surface-control
    pkgs.surface_firmware
  ];
}
