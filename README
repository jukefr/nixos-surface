### Buy me covfefe ❤️
```
BTC     bc1qjqzkrfupcrgtzpeu0pmut24vq8tfzs9rqe6458
ETH     0x799b3b5520525CDd95d1D5C7Ba1a2Ee6037B1bFE
ADA     addr1q8mz3z7cw4jz9dacvpz6dpw2c6xke6nv8vk6rfnt7mkaat8vgnu796g5vrarn4pjgpdqkare9zryx645e25wcae8636q97typg
XRP     r3Bpcyp8zVNkaDzpppdRTuSXSvxAUJXAVj
LTC     ltc1qpja2nr6x9nz3q3ya3ec6ec5hxvm8dz52urn39z
BCH     1NAteBJF7wKw8BdzLJ6YE65ja1ZAHf68jf
DOGE    DL4VNBx6EGuPcgnJrfgxok9tTvcbVGKx3R
XMR     89S6qYdMJyZZ8ddKtFqTzGhuDZxJkNcmL9L6KzTSw7AeQos1uku2GBhBaHLUYtgv4TQRRQuNF4FixAu6geKC2r25NyWZj2Q
DASH    XtffD9gZFDKWWpabMyAi8sF9EeDREH5dUy
DCR     DsSAqeDekTCvbd84GkAofHyutrFrFDX1EnD
ZEC     t1P336iRRMM6Yu2wTzXJmjm6p4RgNAQkgsM
STRAX   SVfFcCZtQ8yMSMxc2K8xzFr4psHpGpnKNT 
```

Add nixos-surface/surface.nix to your imports in configuration.nix:

imports =
  [
  ...
  ./surface-nixos/surface.nix
  ];
  
surface-control.nix and surface-dtx-daemon.nix depend on nixos-20.03

Try using cachix to skip building the kernel: cachix use nixos-surface

Example surface-dtx-daemon configuration:
  services.surface-dtx-daemon = {
    enable = true;
    attach = ''
      #!/usr/bin/env bash
      source /etc/profile
      fsck -y /dev/disk/by-uuid/l2v7ne76-7efa-4236-a096-108xb7ck82b
      mount /home/.card
    '';
    detach = ''
      #!/usr/bin/env bash
      source /etc/profile
      for usb_dev in /dev/disk/by-id/usb-*
       do
          dev=$(readlink -f $usb_dev)
          mount -l | grep -q "^$dev\s" && umount "$dev"
       done
      umount -A /dev/disk/by-uuid/l2v7ne76-7efa-4236-a096-108xb7ck82bf
      for name in $(sudo -u user VBoxManage list runningvms | cut -d " " -f 2);
        do
          sudo -u user VBoxManage controlvm $name savestate
        done
      exit $EXIT_DETACH_COMMENCE
    '';
  };
