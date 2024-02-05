{
  description = "C++ Crosscompilation Example";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = let
          # Override the stdenv for darwin as we need to use the 11.0 sdk and not 10.x
          stdenv = if pkgs.stdenv.isDarwin then
            pkgs.darwin.apple_sdk_11_0.stdenv
          else
            pkgs.stdenv;
        in {
          default = pkgs.callPackage ./package.nix { stdenv = stdenv; };

          static = pkgs.callPackage ./package.nix {
            stdenv = stdenv;
            static = true;
          };

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix { };
        };
      };
      flake = { };
    };
}
