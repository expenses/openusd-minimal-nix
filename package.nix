{ stdenv, lib, cmake, boost, tbb_2021_8, libGL, opensubdiv, darwin, xorg
, embree, draco, vulkan-sdk, openimageio, openexr, imath, materialx
, static ? false
, buildTests ? false
, buildExamples ? false
, buildMonolithic ? false
, embreeSupport ? false
, dracoSupport ? false
, openimageioSupport ? false
, materialxSupport ? false
, vulkanSupport ? false
}:
stdenv.mkDerivation {
  name = "openusd-minimal";

  # good source filtering is important for caching of builds.
  # It's easier when subprojects have their own distinct subfolders.
  src = fetchGit {
    url = "https://github.com/pixaranimationstudios/openusd";
    rev = "0244f25c9fb7ead390e810b9ddb11471a0603961";
  };

  # Distinguishing between native build inputs (runnable on the host
  # at compile time) and normal build inputs (runnable on target
  # platform at run time) is important for cross compilation.
  nativeBuildInputs = [ cmake ];

  VULKAN_SDK = if vulkanSupport then "${vulkan-sdk}" else "";

  patches = [ ./windows-plus-onetbb.patch ]
    ++ lib.optionals vulkanSupport [ ./vulkan.patch ]
  ;

  buildInputs = [
    boost
    (tbb_2021_8.override { static = !stdenv.targetPlatform.isWindows; })
    opensubdiv.static
    opensubdiv.dev
  ] ++ lib.optionals (!stdenv.targetPlatform.isWindows) ([ libGL ])
    ++ lib.optionals stdenv.isLinux ([ xorg.libX11 ])
    ++ lib.optionals stdenv.isDarwin
    ([ darwin.moltenvk ] ++ (with darwin.apple_sdk_11_0.frameworks; [ Cocoa MetalKit ]))
    ++ lib.optionals embreeSupport ([ embree ])
    ++ lib.optionals dracoSupport ([ draco ])
    ++ lib.optionals openimageioSupport ([ openimageio openexr imath ])
    ++ lib.optionals materialxSupport ([ materialx ])
  ;

  cmakeFlags = [
    (lib.cmakeBool "PXR_ENABLE_PYTHON_SUPPORT" false)
    (lib.cmakeBool "OneTBB_CMAKE_ENABLE" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!static))
    (lib.cmakeBool "PXR_BUILD_TESTS" buildTests)
    (lib.cmakeBool "PXR_BUILD_EXAMPLES" buildExamples)
    (lib.cmakeBool "PXR_BUILD_MONOLITHIC" buildMonolithic)
    (lib.cmakeBool "PXR_BUILD_EMBREE_PLUGIN" embreeSupport)
    (lib.cmakeBool "PXR_BUILD_DRACO_PLUGIN" dracoSupport)
    (lib.cmakeBool "PXR_BUILD_OPENIMAGEIO_PLUGIN" openimageioSupport)
    (lib.cmakeBool "PXR_ENABLE_MATERIALX_SUPPORT" materialxSupport)
    (lib.cmakeBool "PXR_ENABLE_VULKAN_SUPPORT" vulkanSupport)
  ];
}
