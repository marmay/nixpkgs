{ lib, version, hash, stdenv, fetchurl, nixosTests, writeScript }:

stdenv.mkDerivation rec {
  pname = "wordpress";
  inherit version;

  src = fetchurl {
    url = "https://wordpress.org/${pname}-${version}.tar.gz";
    inherit hash;
  };

  installPhase = ''
    mkdir -p $out/share/wordpress
    cp -r . $out/share/wordpress
  '';

  passthru.tests = {
    inherit (nixosTests) wordpress;
  };

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts jq
    set -eu -o pipefail
    version=$(curl --globoff "https://api.wordpress.org/core/version-check/1.7/" | jq -r '.offers[0].version')
    update-source-version wordpress $version
  '';

  meta = with lib; {
    homepage = "https://wordpress.org";
    description = "WordPress is open source software you can use to create a beautiful website, blog, or app";
    license = [ licenses.gpl2 ];
    maintainers = [ maintainers.basvandijk ];
    platforms = platforms.all;
  };
}
