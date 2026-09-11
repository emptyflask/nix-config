{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-calc
      rofimoji
    ];
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "gruvbox-dark";
  };
}
