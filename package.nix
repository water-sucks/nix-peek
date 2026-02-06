{
  lib,
  stdenv,
  nix-gitignore,
  zig,
  pkg-config,
  nix,
  fetchZigDeps,
}: let
  pname = "nix-peek";
  version = "0.0.1";
  src = nix-gitignore.gitignoreSource [] ./.;

  deps = fetchZigDeps {
    inherit pname version src zig stdenv;
    hash = "sha256-kK+8Cww0ibwRdN2uedQXceKxxO+sAjK5YtaGoBq1oIQ=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    postPatch = ''
      ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
      export ZIG_GLOBAL_CACHE_DIR

      ln -s ${deps} "$ZIG_GLOBAL_CACHE_DIR/p"
    '';

    nativeBuildInputs = [zig.hook pkg-config];
    buildInputs = [nix.dev];

    buildPhase = ''
      TERM=dumb zig build \
        --release=safe \
        -Dcpu=baseline \
        --cache-dir $ZIG_GLOBAL_CACHE_DIR \
        --global-cache-dir $ZIG_GLOBAL_CACHE_DIR
    '';
    #
    installPhase = ''
      TERM=dumb zig build install \
        -Dcpu=baseline \
        --release=safe \
        --prefix $out \
        --cache-dir $ZIG_GLOBAL_CACHE_DIR \
        --global-cache-dir $ZIG_GLOBAL_CACHE_DIR
    '';

    meta = {
      homepage = "https://github.com/water-sucks/nix-peek";
      description = "View Nix attrset values inside of a file browser-like UI";
      changelog = "https://github.com/water-sucks/nix-peek/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [water-sucks];
      mainProgram = "nix-peek";
    };
  })
