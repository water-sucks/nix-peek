{
  description = "Zig bindings to Nix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix.url = "github:nixos/nix/2.30.2";

    zig-deps-fod.url = "github:water-sucks/zig-deps-fod";
    zig-deps-fod.inputs.nixpkgs.follows = "nixpkgs";
    zig-deps-fod.inputs.flake-parts.follows = "flake-parts";

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

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) zig pkg-config;
        nixPackage = inputs.nix.packages.${system}.nix;
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
