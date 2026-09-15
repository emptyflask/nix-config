# Run restic against the b2 backup repo for a given host, decrypting the
# agenix secrets in-memory (never to disk). Usage:
#   restic-b2 newton snapshots
#   restic-b2 kepler restore latest --target /tmp/restore-out
#   restic-b2 kepler restore latest:/home/jon/notes --include /Cookbook --target ~/notes
{
  writeShellScriptBin,
  restic,
}:
writeShellScriptBin "restic-b2" ''
  set -euo pipefail

  host="''${1:-}"
  case "$host" in
    newton)
      pw_file="secrets/newton-restic-password.age"
      b2_file="secrets/newton-restic-b2-env.age"
      ;;
    kepler)
      pw_file="secrets/restic-password.age"
      b2_file="secrets/restic-b2-env.age"
      ;;
    *)
      printf 'usage: restic-b2 <newton|kepler> <restic args...>\n' >&2
      exit 1
      ;;
  esac
  shift

  # agenix resolves its RULES lookup (./secrets.nix) by the exact relative
  # path string passed to it, so this must run from the repo root.
  repo_dir="$HOME/dev/nix-config"
  identity="$HOME/.ssh/id_agenix"
  cd "$repo_dir"

  set -a
  source <(agenix -d "$b2_file" -i "$identity")
  set +a
  export RESTIC_REPOSITORY="b2:emptyflask-backup:$host"
  export RESTIC_PASSWORD
  RESTIC_PASSWORD="$(agenix -d "$pw_file" -i "$identity")"

  exec ${restic}/bin/restic "$@"
''
