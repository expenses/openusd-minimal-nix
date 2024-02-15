{ stdenv, lib, cmake, boost, tbb, libGL, opensubdiv, darwin, xorg, embree, draco
, vulkan-sdk, vulkan-loader, openimageio, openexr, imath, materialx
, static ? false
, monolithic ? false
, embreeSupport ? false
, dracoSupport ? false
, openimageioSupport ? false
, materialxSupport ? false
, vulkanSupport ? false }:
stdenv.mkDerivation {
  name = "openusd-minimal";

  # good source filtering is important for caching of builds.
  # It's easier when subprojects have their own distinct subfolders.
  src = fetchGit {
    url = "https://github.com/pixaranimationstudios/openusd";
    ref = "refs/tags/v23.11";
    rev = if vulkanSupport then "0244f25c9fb7ead390e810b9ddb11471a0603961" else "0b18ad3f840c24eb25e16b795a5b0821cf05126e";
  };

  # Distinguishing between native build inputs (runnable on the host
  # at compile time) and normal build inputs (runnable on target
  # platform at run time) is important for cross compilation.
  nativeBuildInputs = [ cmake ];

  VULKAN_SDK = if vulkanSupport then "${vulkan-sdk}" else "";

  patches = lib.optionals vulkanSupport [ ./vulkan.patch ];

  buildInputs = [ boost tbb libGL opensubdiv ]
    ++ lib.optionals stdenv.isLinux ([ xorg.libX11 ])
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk_11_0.frameworks; [ Cocoa MetalKit ])
    ++ lib.optionals embreeSupport ([ embree ])
    ++ lib.optionals dracoSupport ([ draco ])
    ++ lib.optionals openimageioSupport ([ openimageio openexr imath ])
    ++ lib.optionals materialxSupport ([ materialx ])
    ++ lib.optionals vulkanSupport ([ vulkan-loader ]);

  cmakeFlags = [ "-DPXR_ENABLE_PYTHON_SUPPORT=false" ]
    ++ lib.optionals static ([ "-DBUILD_SHARED_LIBS=false" ])
    ++ lib.optionals monolithic ([ "-DPXR_BUILD_MONOLITHIC=true" ])
    ++ lib.optionals embreeSupport ([ "-DPXR_BUILD_EMBREE_PLUGIN=true" ])
    ++ lib.optionals dracoSupport ([ "-DPXR_BUILD_DRACO_PLUGIN=true" ])
    ++ lib.optionals openimageioSupport
    ([ "-DPXR_BUILD_OPENIMAGEIO_PLUGIN=true" ])
    ++ lib.optionals materialxSupport
    ([ "-DPXR_ENABLE_MATERIALX_SUPPORT=true" ])
    ++ lib.optionals vulkanSupport ([ "-DPXR_ENABLE_VULKAN_SUPPORT=true" ]);
}
