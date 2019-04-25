let

  fetchNixpkgs = { rev, sha256 }: builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
  };

  pkgs = import (fetchNixpkgs {
    # pin nixos-19.03: 2019-04-24T11:23:05+02:00
    rev = "2f1eacc949fe31f34d7af4ebfd97c01a02ceee16";
    sha256 = "1nvx87xc1yiv6zkp34mdwhxrgsg4idncpy7zvc7cs3qw918hflfs";
  }) {};

in pkgs.stdenv.mkDerivation rec {
  src = pkgs.lib.cleanSource ./.;
  name = "website";

  buildInputs = [
    pkgs.python27Packages.lektor
  ];

  installPhase = ''
    mkdir -p $out
    lektor build -O $out
  '';

  shellHook = ''
    lektor server -h 0.0.0.0 -p 5001
  '';
}
