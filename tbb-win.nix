{ stdenv, fetchurl, zstd }:
stdenv.mkDerivation {
  name = "tbb-2020.3-win";

  src = fetchurl({
    url = "https://repo.msys2.org/mingw/mingw64/mingw-w64-x86_64-intel-tbb-1~2020.3-2-any.pkg.tar.zst";
    hash = "sha256-U4osrbGXjsWtjYP993VsvsTFlhpwlCQ6oIh/jtvsVqA=";
  });

  buildInputs = [zstd];

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
