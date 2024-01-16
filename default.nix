let

  pkgs = import (builtins.fetchGit {
    name = "nixos-23.11";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-23.11";
    rev = "b8dd8be3c790215716e7c12b247f45ca525867e2";
    }) {};

  site = pkgs.stdenv.mkDerivation rec {
    src = pkgs.lib.cleanSource ./.;
    name = "website";

    buildInputs = with pkgs; [
      imagemagick
      python38Packages.lektor
    ];

    installPhase = ''
        mkdir -p $out
        lektor build -O $out
    '';
  };

  scheduler = import (pkgs.fetchFromGitHub {
    owner = "section77";
    repo = "chaostreff-scheduler";
    rev = "7bc8f3ec4b2aa889d939eaa9e5076e291def9847";
    sha256 = "sha256-YRkERoly02v3ZEnD5LKtyTT6eBAKwAb8b3pUSZ8PUD0=";
  });
  #scheduler = import ../chaostreff-scheduler ;

  schedule = pkgs.stdenv.mkDerivation rec {
    name = "schedule";
    src = ./.;
    buildInputs = [ scheduler pkgs.git ];
    installPhase = ''
      mkdir $out

      export HOME=$TEMP
      git config --global user.name "chaostreff-scheduler"
      git config --global user.email "chaostreff-scheduler@section77.de"

      chaostreff-scheduler --no-push -r $src -w $out -c 2
    '';
  };
in
if pkgs.lib.inNixShell then pkgs.mkShell {
  buildInputs = site.buildInputs;

  shellHook = ''
    lektor server -h 0.0.0.0 -p 5001
  '';
}
else {
  inherit site schedule;
}

