{
  description = "C++ Crosscompilation Example";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = {
          default = pkgs.callPackage ./package.nix { };

          static = pkgs.callPackage ./package.nix { static = true; };

          apple-sdk-11 = pkgs.darwin.apple_sdk_11_0.callPackage ./package.nix {};

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix { };
        };
      };
      flake = { };
    };
}
