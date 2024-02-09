{
  description = "C++ Crosscompilation Example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

          static = pkgs.callPackage ./package.nix (args // { static = true; });

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix (args // {
            stdenv = pkgs.pkgsCross.mingwW64.stdenv;
            tbb = pkgs.callPackage ./tbb-win.nix { };
            opensubdiv =
              pkgs.pkgsCross.mingwW64.callPackage ./opensubdiv-win-msys2.nix
              { };
            static = true;
          });
        };
      };
      flake = { };
    };
}
