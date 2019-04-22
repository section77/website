{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
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
