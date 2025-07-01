let
  pkgs = import (builtins.fetchGit {
    name = "nixos-24.11";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-24.11";
    rev = "3f0a8ac25fb674611b98089ca3a5dd6480175751";
  }) {};

  site = pkgs.stdenv.mkDerivation {
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
    rev = "f60231f0a8f01b2752a7f8c445fd180e803c66ff";
    sha256 = "sha256-CRnEpogLtfbXAIB9TIbkD9VorDmAcVTSEslDxydmyPg=";
  });

  schedule = pkgs.stdenv.mkDerivation {
    name = "schedule";
    src = ./.;
    buildInputs = [scheduler pkgs.git];
    installPhase = ''
      mkdir $out

      export HOME=$TEMP
      git config --global user.name "chaostreff-scheduler"
      git config --global user.email "chaostreff-scheduler@section77.de"

      chaostreff-scheduler --no-push -r $src -w $out -c 2
    '';
  };
in
  if pkgs.lib.inNixShell
  then
    pkgs.mkShell {
      buildInputs = site.buildInputs;

      shellHook = ''
        lektor server -h 0.0.0.0 -p 5001
      '';
    }
  else {
    inherit site schedule;
  }
