{
  pkgs,
  claude-code,
  ...
}: {
  modules = [
    {
      nixpkgs.overlays = [claude-code.overlays.default];
    }
  ];
  programs.claude-code = {
    enable = true;
  };
}
