# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };
  restic-b2 = pkgs.callPackage ./restic-b2 {};
  restic-local = pkgs.callPackage ./restic-local {};
}
