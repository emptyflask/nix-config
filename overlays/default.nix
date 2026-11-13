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

    # Electron 43.8.3 breaks Obsidian's renderer (webFrame "Cannot read
    # properties of undefined (reading 'defineProperty')" -> blank window);
    # 43.7.11 and 44.x are fine. Drop once nixpkgs' electron_43 is fixed.
    obsidian = prev.obsidian.override {electron = final.electron_44;};

    # mplayer's dvdnav support links the ancient libdvdnav_4_2_1 (and its
    # libdvdread.so.4), which shadows the current libdvdnav that ffmpeg_7's
    # libavformat was built against, so the final link fails on an undefined
    # `dvdnav_open2`. Backport of nixpkgs#584772 (merged to master
    # 2026-11-09); once nixos-unstable has it, the libdvdnav_4_2_1 argument
    # is gone and this override errors out, so delete it then.
    mplayer = prev.mplayer.override {libdvdnav_4_2_1 = final.libdvdnav;};

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
