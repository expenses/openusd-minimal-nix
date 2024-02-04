{
  description = "C++ Crosscompilation Example";

  inputs = { nixpkgs.url = "path:/Users/ashley/nixpkgs"; };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = {
          babble = pkgs.callPackage ./package.nix { };
          default = config.packages.babble;

          apple-sdk-11 = pkgs.darwin.apple_sdk_11_0.callPackage ./package.nix {};

          x86 = pkgs.pkgsCross.gnu64.callPackage ./package.nix { };
          x86-static =
            pkgs.pkgsCross.gnu64.pkgsStatic.callPackage ./package.nix { };
          aarch64 =
            pkgs.pkgsCross.aarch64-multiplatform.callPackage ./package.nix { };
          aarch64-static =
            pkgs.pkgsCross.aarch64-multiplatform.pkgsStatic.callPackage
            ./package.nix { };

          windows = pkgs.pkgsCross.mingwW64.callPackage ./package.nix { };
        };
      };
      flake = { };
    };
}
