{
  lib,
  stdenv,
  zig,
  pkg-config,
  nix,
  fetchZigDeps,
}: let
  name = "nix-peek";

  deps = fetchZigDeps {
    inherit name zig stdenv;
    src = ./.;
    depsHash = "sha256-V5KY4Az6UpjwaO+YkqwlFLn2lJTL2p8JyGjkX+BLWlo=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = name;
    version = "0.0.1";
    src = ./.;

    postPatch = ''
      ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
      export ZIG_GLOBAL_CACHE_DIR

      ln -s ${deps} "$ZIG_GLOBAL_CACHE_DIR/p"
    '';

    nativeBuildInputs = [zig.hook pkg-config];
    buildInputs = [nix.dev];

    meta = {
      homepage = "https://github.com/water-sucks/nix-peek";
      description = "View Nix attrset values inside of a file browser-like UI";
      changelog = "https://github.com/water-sucks/nix-peek/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [water-sucks];
      mainProgram = "nix-peek";
    };
  })
