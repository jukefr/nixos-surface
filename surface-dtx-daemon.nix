{stdenv, fetchurl, rustPlatform, pkg-config, dbus}:
rustPlatform.buildRustPackage rec {
  name = "surface-dtx-daemon-${version}";
  version = "0.1.4-3";
  src = fetchurl {
    url = "https://github.com/linux-surface/surface-dtx-daemon/archive/v${version}.tar.gz";
    sha256 = "1qn85ywk069chw0w8ygvxfl8b0i94qybhhf1k144hdb4ykhp33mw";
  };

  patches = [ ./service.patch ];

  buildInputs = [ dbus ];
nativeBuildInputs = [ pkg-config ];

  cargoSha256 = "0544f6c0wmraasamhh8dhq37g07wqk5karr3g87wzwaw6pqp69vj";

  postInstall = ''
    mkdir -p $out/etc/udev/rules.d
    cp etc/udev/40-surface_dtx.rules $out/etc/udev/rules.d/

    mkdir -p $out/etc/systemd/system
    cp etc/systemd/*.service $out/etc/systemd/system/

    mkdir -p $out/etc/dbus-1/system.d
    cp etc/dbus/org.surface.dtx.conf $out/etc/dbus-1/system.d/

    mkdir -p $out/etc/dtx
    cp etc/dtx/*.conf $out/etc/dtx/
  '';
}
