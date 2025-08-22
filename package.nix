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
    depsHash = "sha256-i7q9zIMK0UQkcUhTc1LLdoJ7YPWaI1XLwsw1zdu+j9A=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = name;
    version = "0.0.1";
    src = ./.;

    nativeBuildInputs = [zig.hook pkg-config];
    buildInputs = [nix.dev];

    zigBuildFlags = [
      "--cache-dir"
      "./zig-cache"
      "--global-cache-dir"
      "./.cache"
    ];

    postPatch = ''
      mkdir -p .cache
      ln -s ${deps} .cache/p
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
