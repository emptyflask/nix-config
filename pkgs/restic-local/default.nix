# Run restic against kepler's local backup repo (the removable drive at
# /media/green), decrypting the agenix secret in-memory (never to disk).
# Usage:
#   restic-local snapshots
#   restic-local restore latest --target /tmp/restore-out
{
  writeShellScriptBin,
  restic,
}:
writeShellScriptBin "restic-local" ''
  set -euo pipefail

  # agenix resolves its RULES lookup (./secrets.nix) by the exact relative
  # path string passed to it, so this must run from the repo root.
  repo_dir="$HOME/dev/nix-config"
  identity="$HOME/.ssh/id_agenix"
  cd "$repo_dir"

  export RESTIC_REPOSITORY="/media/green/restic"
  export RESTIC_PASSWORD
  RESTIC_PASSWORD="$(agenix -d secrets/restic-password.age -i "$identity")"

  # the backup service runs as root, so the repo dir is root:root 700
  exec sudo -E ${restic}/bin/restic "$@"
''
