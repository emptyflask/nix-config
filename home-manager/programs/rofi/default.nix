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
    settings.terminal = "${pkgs.kitty}/bin/kitty";
    theme = "gruvbox-dark";
  };
}
