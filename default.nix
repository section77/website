let

  pkgs = import (builtins.fetchGit {
    name = "nixos-21.05";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-21.05";
    rev = "a1007637cea374bd1bafd754cfd5388894c49129";
    }) {};

  site = pkgs.stdenv.mkDerivation rec {
    src = pkgs.lib.cleanSource ./.;
    name = "website";

    buildInputs = with pkgs; [
      imagemagick
      python27Packages.lektor
    ];

    installPhase = ''
        mkdir -p $out
        lektor build -O $out
    '';
  };

  scheduler = import (pkgs.fetchFromGitHub {
    owner = "section77";
    repo = "chaostreff-scheduler";
    rev = "668df414643ad56e434ea8041ebbad8b6ce61452";
    sha256 = "17l1aqzag44amilqm0sjdkgykfq8vvcxwv12qz307clz0imzb1hr";
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

