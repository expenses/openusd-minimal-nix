{ stdenv, lib, cmake, boost, tbb, libGL, opensubdiv, darwin, xorg, embree, draco, windows, clang, gcc
, openimageio, openexr, imath, materialx, static ? false, embreeSupport ? false
, dracoSupport ? false, openimageioSupport ? false, materialxSupport ? false }:
stdenv.mkDerivation {
  name = "openusd-minimal";

  # good source filtering is important for caching of builds.
  # It's easier when subprojects have their own distinct subfolders.
  src = fetchGit {
    url = "/home/ashley/projects/OpenUSD";
    rev = "9b19d56b05ccf6f553d9c6294e35b65597408a70";
  };

  # Distinguishing between native build inputs (runnable on the host
  # at compile time) and normal build inputs (runnable on target
  # platform at run time) is important for cross compilation.
  nativeBuildInputs = [ cmake];

  buildInputs = [ boost  tbb opensubdiv ]
    #++ lib.optionals stdenv.isLinux ([ xorg.libX11 ])
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk_11_0.frameworks; [ Cocoa MetalKit ])
    ++ lib.optionals embreeSupport ([ embree ])
    ++ lib.optionals dracoSupport ([ draco ])
    ++ lib.optionals openimageioSupport ([ openimageio openexr imath ])
    ++ lib.optionals materialxSupport ([ materialx ]);

  cmakeFlags = [ "-DPXR_ENABLE_PYTHON_SUPPORT=false"
  #"-DTBB_ROOT_DIR=${tbb}"
  #"-DTBB_INCLUDE_DIR=${tbb}/include"
  #"-DTBB_LIBRARY=${tbb}/lib/intel64/vc14"
  "-DPXR_BUILD_TESTS=false"
  "-DCMAKE_CXX_EXTENSIONS=on"
  ]
    ++ lib.optionals embreeSupport ([ "-DPXR_BUILD_EMBREE_PLUGIN=true" ])
    ++ lib.optionals dracoSupport ([ "-DPXR_BUILD_DRACO_PLUGIN=true" ])
    ++ lib.optionals openimageioSupport
    ([ "-DPXR_BUILD_OPENIMAGEIO_PLUGIN=true" ])
    ++ lib.optionals materialxSupport
    ([ "-DPXR_ENABLE_MATERIALX_SUPPORT=true" ])
    ++ lib.optionals static ([ "-DBUILD_SHARED_LIBS=false" ]);
}
