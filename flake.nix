{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaostreff-scheduler.url = "github:section77/chaostreff-scheduler?rev=f60231f0a8f01b2752a7f8c445fd180e803c66ff";
    chaostreff-scheduler.flake = false;
  };

  outputs = { self, nixpkgs, chaostreff-scheduler }: 
  let
    forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      pkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
        }
      );
  in
  rec
  { 
    packages = forAllSystems (system: 
    let
      pkgs = pkgsFor.${system};
    in
    {
      scheduler = pkgs.haskellPackages.developPackage {
          root = chaostreff-scheduler;
      };
      site = pkgs.stdenvNoCC.mkDerivation {
        name = "website";
        src = self;

        nativeBuildInputs = with pkgs; [
          imagemagick
          lektor
        ];

        installPhase = ''
          mkdir -p $out
          lektor build -O $out
        '';
      };
    });
    apps = forAllSystems (system:
    let
      pkgs = pkgsFor.${system};
      scheduler = packages.${system}.scheduler;
    in
    rec
    {
      schedule = {
        type = "app";
        program = "${pkgs.writeShellScript "schedule" ''
            export HOME=$TEMP
            ${pkgs.git}/bin/git config --global user.name "chaostreff-scheduler"
            ${pkgs.git}/bin/git config --global user.email "chaostreff-scheduler@section77.de"

            ${scheduler}/bin/chaostreff-scheduler --no-push -r . -w . -c 2
        ''}";
      };
      default = schedule;
    });
    devShells = forAllSystems (system:
    let
      pkgs = pkgsFor.${system};
    in
    {
      default = pkgs.mkShellNoCC {
        nativeBuildInputs = packages.${system}.site.nativeBuildInputs;
        shellHook = ''
          ${pkgs.lektor}/bin/lektor server -h 0.0.0.0 -p 5001
        '';
      };
    });
  };
}
