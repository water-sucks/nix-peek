{
  description = "Zig bindings to Nix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    zig-deps-fod.url = "github:water-sucks/zig-deps-fod";
    # zig-deps-fod.inputs.nixpkgs.follows = "nixpkgs";
    # zig-deps-fod.inputs.flake-parts.follows = "flake-parts";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];

      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {pkgs, ...}: let
        inherit (pkgs) zig pkg-config;

        nixPackage = pkgs.nixVersions.nix_2_33;
      in {
        devShells.default = pkgs.mkShell {
          name = "nix-peek-shell";

          nativeBuildInputs = [
            zig
            pkg-config
          ];

          buildInputs = [
            nixPackage.dev
          ];

          shellHook = ''
            export ZIG_GLOBAL_CACHE_DIR=$HOME/.cache/zig
          '';
        };

        packages = let
          nix-peek = pkgs.callPackage ./package.nix {
            inherit (inputs.zig-deps-fod.lib) fetchZigDeps;
            nix = nixPackage;
          };
        in {
          inherit nix-peek;
          default = nix-peek;
        };
      };
    };
}
