let

  pkgs = import (builtins.fetchGit {
    name = "nixos-23.11";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-23.11";
    rev = "a77ab169a83a4175169d78684ddd2e54486ac651";
    }) {};

  site = pkgs.stdenv.mkDerivation rec {
    src = pkgs.lib.cleanSource ./.;
    name = "website";

    buildInputs = with pkgs; [
      imagemagick
      lektor
    ];

    installPhase = ''
        mkdir -p $out
        lektor build -O $out
    '';
  };

  scheduler = import (pkgs.fetchFromGitHub {
    owner = "section77";
    repo = "chaostreff-scheduler";
    rev = "60f8fcf5021b13a12de86fdfacbbd0cbb13c89a0";
    sha256 = "sha256-y48XkvQIbekBcfzVqKWo4ZtJckLEB+hxTXFW69pz48M=";
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

