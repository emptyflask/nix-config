{ den, ... }: {
  den.aspects.desktop.homeManager = { pkgs, ... }: {
    imports = [
      ../../home-manager/programs/rofi
      ../../home-manager/programs/yazi
      ../../home-manager/programs/zathura
      ../../home-manager/services/dunst
      ../../home-manager/services/trayer
      ../../home-manager/xmobar
      ../../home-manager/xresources
    ];
    xsession.windowManager = import ../../home-manager/xmonad pkgs;
  };
}
