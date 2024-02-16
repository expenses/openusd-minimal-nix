{
  description = "C++ Crosscompilation Example";

  inputs = {
    nixpkgs.url = "/home/ashley/projects/nixpkgs";
    materialx.url = "github:expenses/materialx-nix";
    materialx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, materialx, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = let
          args = {
            # Override the stdenv for darwin as we need to use the 11.0 sdk and not 10.x
            stdenv = if pkgs.stdenv.isDarwin then
              pkgs.darwin.apple_sdk_11_0.stdenv
            else
              pkgs.stdenv;
            materialx = materialx.packages.${system}.default;
            vulkan-sdk = pkgs.callPackage ./vulkan-sdk.nix { };
          };
          fullArgs = args // {
            embreeSupport = true;
            dracoSupport = true;
            openimageioSupport = true;
            materialxSupport = true;
          };
        in {
          default = pkgs.callPackage ./package.nix args;
          full = pkgs.callPackage ./package.nix fullArgs;

          vulkan-sdk = args.vulkan-sdk;

          static = pkgs.callPackage ./package.nix (args // { static = true; });
          vulkan = pkgs.callPackage ./package.nix (args // { vulkanSupport = true; });

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix (args // {
            stdenv = pkgs.pkgsCross.mingwW64.stdenv;
            tbb = pkgs.callPackage ./msys2-packages/tbb-2020.nix { };
            opensubdiv = pkgs.pkgsCross.mingwW64.callPackage
              ./msys2-packages/opensubdiv.nix { };
            static = true;
            vulkanSupport = true;
            vulkan-sdk = pkgs.pkgsCross.mingwW64.callPackage ./vulkan-sdk.nix { };
          });
        };
      };
      flake = { };
    };
}
