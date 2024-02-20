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
          vulkan-sdk = pkgs.callPackage ./vulkan-sdk.nix { };
          vulkan-sdk-win =
            pkgs.pkgsCross.mingwW64.callPackage ./vulkan-sdk.nix { };
        in rec {
          default = pkgs.callPackage ./package.nix {
            inherit vulkan-sdk;
            # Override the stdenv for darwin as we need to use the 11.0 sdk and not 10.x
            stdenv = if pkgs.stdenv.isDarwin then
              pkgs.darwin.apple_sdk_11_0.stdenv
            else
              pkgs.stdenv;
            materialx = materialx.packages.${system}.default;
          };
          vulkan = default.override { vulkanSupport = true; };
          static = default.override { static = true; };
          full = default.override {
            embreeSupport = true;
            dracoSupport = true;
            openimageioSupport = true;
            materialxSupport = true;
            vulkanSupport = true;
          };

          inherit vulkan-sdk vulkan-sdk-win;

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix {
            static = true;
            vulkan-sdk = vulkan-sdk-win;
            vulkanSupport = true;
            materialx = materialx.packages.${system}.default;
          };
        };
      };
      flake = { };
    };
}
