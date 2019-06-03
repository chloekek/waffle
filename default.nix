{pkgs ? import ./nix/pkgs.nix {}}:
pkgs.stdenv.mkDerivation {
    name = "waffle";
    src = pkgs.lib.cleanSource ./.;
    buildInputs = [pkgs.dmd];
    phases = ["unpackPhase" "buildPhase" "installPhase"];
    buildPhase = ''
        dmdFlags=(-color)
        dSources() { find src -name '*.d' -type f -print0; }
        compileD() { dSources | xargs -0 dmd "''${dmdFlags[@]}" "$@"; }
        compileD -debug -unittest -main -of=libwaffle.test
        compileD -debug -shared -of=libwaffle.debug.so
        compileD -O -inline -release -shared -of=libwaffle.release.so
    '';
    installPhase = ''
        mkdir --parents $out/{bin,lib}
        mv libwaffle.test $out/bin
        mv libwaffle.{debug,release}.so $out/lib
    '';
}
