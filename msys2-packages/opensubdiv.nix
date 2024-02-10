{ stdenv, fetchurl, zstd }:
stdenv.mkDerivation {
  name = "opensubdiv-msys2";

  src = fetchurl ({
    url =
      "https://mirror.msys2.org/mingw/clang64/mingw-w64-clang-x86_64-opensubdiv-3.6.0-1-any.pkg.tar.zst";
    hash = "sha256-5rcw0V/HpkBeH/hPv+tzHp2cmR/KdPnLR+/IlLPNY+E=";
  });

  nativeBuildInputs = [ zstd ];

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
