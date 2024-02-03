{ stdenv, lib, cmake, boost, tbb, libGL, opensubdiv, darwin, xorg }:
stdenv.mkDerivation {
  name = "openusd-minimal";

  # good source filtering is important for caching of builds.
  # It's easier when subprojects have their own distinct subfolders.
  src = fetchGit {
    url = "https://github.com/pixaranimationstudios/openusd";
    ref = "refs/tags/v23.11";
    rev = "0b18ad3f840c24eb25e16b795a5b0821cf05126e";
  };

  # Distinguishing between native build inputs (runnable on the host
  # at compile time) and normal build inputs (runnable on target
  # platform at run time) is important for cross compilation.
  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost tbb libGL opensubdiv xorg.libX11 ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [Cocoa Metal MetalKit]);

  cmakeFlags = [
    "-DPXR_ENABLE_PYTHON_SUPPORT=false"
  ];
}
