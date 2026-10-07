# Media gateway that exposes a qBittorrent/SABnzbd-compatible API backed by
# debrid services (Premiumize, RealDebrid, etc) and Usenet, so the *arrs can
# use it as a drop-in download client. Not in nixpkgs as of this writing.
#
# The web UI's CSS/JS (pkg/server/assets/build/) is checked into the repo
# pre-built - upstream's own release Dockerfile just runs `go build` with no
# npm step - so this skips the npm/tailwind toolchain entirely.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  fuse3,
}:
buildGoModule rec {
  pname = "decypharr";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "sirrobot01";
    repo = "decypharr";
    rev = "v${version}";
    hash = "sha256-2Ni1st4QhqT3hlBHPSWJGUdBRxv9hLBzMqAjfES2tmE=";
  };

  vendorHash = "sha256-OgCTd2Y2G+6TimweI14fbSfWyJH2NhJb5JnPsgJL45s=";

  # Picks cgofuse's libfuse3 cgo branch (FUSE_USE_VERSION=39) instead of its
  # default libfuse2 one (FUSE_USE_VERSION=28, incompatible with nixpkgs'
  # fuse3 headers, which require >=30).
  tags = ["fuse3"];

  # winfsp/cgofuse's Linux backend is a cgo binding onto libfuse, needed even
  # though we'll run with mount.type "none" (Premiumize files delivered via
  # plain download, no FUSE mount) - the package still has to compile. Its
  # cgo directive hardcodes `-I/usr/include/fuse` (FHS path, meaningless in
  # the Nix sandbox) rather than going through pkg-config, so point it at
  # fuse3's real header location ourselves; the bogus hardcoded `-I` is
  # harmless since it just resolves to nothing.
  nativeBuildInputs = [pkg-config];
  buildInputs = [fuse3];
  env.CGO_CFLAGS = "-I${fuse3.dev}/include/fuse3";

  # Matches upstream's Dockerfile: `go build` from the module root (the
  # cmd/healthcheck and cmd/test-parser binaries aren't needed here).
  subPackages = ["."];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sirrobot01/decypharr/pkg/version.Version=${version}"
    "-X github.com/sirrobot01/decypharr/pkg/version.Channel=stable"
  ];

  meta = {
    description = "Media gateway exposing a qBittorrent/SABnzbd-compatible API backed by debrid services and Usenet";
    homepage = "https://github.com/sirrobot01/decypharr";
    license = lib.licenses.mit;
    mainProgram = "decypharr";
    platforms = lib.platforms.linux;
  };
}
