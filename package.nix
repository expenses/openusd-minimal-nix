{ stdenv, lib, cmake, boost, tbb, libGL, opensubdiv, darwin, xorg, embree, draco
, openimageio, openexr, imath, materialx, static ? false, embreeSupport ? false
, dracoSupport ? false, openimageioSupport ? false, materialxSupport ? false }:
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

  buildInputs = [ boost tbb libGL opensubdiv ]
    ++ lib.optionals stdenv.isLinux ([ xorg.libX11 ])
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk_11_0.frameworks; [ Cocoa MetalKit ])
    ++ lib.optionals embreeSupport ([ embree ])
    ++ lib.optionals dracoSupport ([ draco ])
    ++ lib.optionals openimageioSupport ([ openimageio openexr imath ])
    ++ lib.optionals materialxSupport ([ materialx ]);

  cmakeFlags = [ "-DPXR_ENABLE_PYTHON_SUPPORT=false" ]
    ++ lib.optionals embreeSupport ([ "-DPXR_BUILD_EMBREE_PLUGIN=true" ])
    ++ lib.optionals dracoSupport ([ "-DPXR_BUILD_DRACO_PLUGIN=true" ])
    ++ lib.optionals openimageioSupport
    ([ "-DPXR_BUILD_OPENIMAGEIO_PLUGIN=true" ])
    ++ lib.optionals materialxSupport
    ([ "-DPXR_ENABLE_MATERIALX_SUPPORT=true" ])
    ++ lib.optionals static ([ "-DBUILD_SHARED_LIBS=false" ]);
}
