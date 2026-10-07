# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # https://lix.systems/add-to-config/
    inherit
      (prev.lixPackageSets.stable)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena
      ;

    karabiner-elements = prev.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";
      src = final.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };
    });

    paperless-ngx = prev.paperless-ngx.overrideAttrs (old: {
      # flaky test: compares timezone.now() against a document's created
      # date derived from file mtime: fails whenever the build straddles
      # local midnight in the test's hardcoded America/Chicago timezone.
      disabledTestPaths =
        (old.disabledTestPaths or [])
        ++ ["src/documents/tests/test_consumer.py::TestConsumer::testNormalOperation"];
    });

    # rxvt-unicode (urxvt) wraps this; overriding it here propagates there too.
    rxvt-unicode-unwrapped = prev.rxvt-unicode-unwrapped.overrideAttrs (old: {
      # rxvtutil.h declares its own free-function `lerp`, found via unqualified
      # lookup alongside `std::lerp` (added in C++20). Nothing here pins a
      # `-std=`, so it inherits whatever newer default GCC picks, and once
      # that default reaches C++20 the two `lerp`s collide as an ambiguous
      # overload - a real compile error, not a warning. Pin an older standard
      # pre-dating std::lerp rather than patch this 2016-vintage, unmaintained
      # upstream's source.
      env =
        (old.env or {})
        // {
          CXXFLAGS = toString ((old.env.CXXFLAGS or []) ++ ["-std=gnu++17"]);
        };
    });

    postman = prev.postman.overrideAttrs (old: rec {
      version = "20230716100528";
      src = final.fetchurl {
        url = "https://web.archive.org/web/${version}/https://dl.pstmn.io/download/latest/linux_64";
        sha256 = "sha256-svk60K4pZh0qRdx9+5OUTu0xgGXMhqvQTGTcmqBOMq8=";
        name = "${old.pname}-${version}.tar.gz";
      };
    });
  };
}
