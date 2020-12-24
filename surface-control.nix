{stdenv, fetchurl, rustPlatform}:
rustPlatform.buildRustPackage rec {
  name = "surface-control-${version}";
  version = "0.2.5-3";
  src = fetchurl {
    url = "https://github.com/qzed/linux-surface-control/archive/v${version}.tar.gz";
    sha256 = "0llimw0xjf2agr1m3f46c9db87wpxjpdm6300l6sgc28vs03cjkg";
  };
  
  cargoSha256 = "01ld3xsl2vzy2sy4w5qsl67y155f87gqn30i1z97j13na3gilsnk";
}
