{ pkgs, ... }:

with pkgs;
{
  # Fills the 264px gap right of xmobar (width 3176, height 26)
  services.stalonetray = {
    enable = true;
    config = {
      geometry = "11x1-0+0";   # 11 slots x 24px = 264px, top-right
      max_geometry = "11x1";
      slot_size = "24x26";     # match xmobar height
      icon_size = 20;
      icon_gravity = "NE";
      grow_gravity = "NE";
      skip_taskbar = true;
      background = "#282828";
      transparent = true;
      tint_color = "#282828";
      tint_level = 192;        # same opacity as xmobar's alpha
      window_strut = "none";
      dockapp_mode = "none";
    };
  };
}
