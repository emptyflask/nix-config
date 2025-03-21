{config, pkgs, ...}:

{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    package = pkgs.yabai;

    config = {
      layout           = "bsp";
      auto_balance     = "off";
      window_topmost   = "on";
      window_placement = "second_child";

      top_padding    = 20;
      bottom_padding = 20;
      left_padding   = 20;
      right_padding  = 20;
      window_gap     = 20;
      external_bar   = "all:26:0";

      window_border              = "on";
      window_border_width        = 2;
      active_window_border_color = "0xff98971a";
      normal_window_border_color = "0xff282828";
      window_border_blur         = "off";
    };

    extraConfig = ''
      yabai -m rule --add app="^System Preferences$" manage=off

      # https://github.com/FelixKratz/JankyBorders installed via homebrew
      # /opt/homebrew/bin/borders active_color=0xff98971a inactive_color=0xff282828 width=4.0 2>/dev/null 1>&2 &

      # Floating for special apps
      yabai -m rule --add app="^1Password$" sticky=off sub-layer=normal manage=off
      yabai -m rule --add app="^Font Book$" sticky=off sub-layer=normal manage=off
      yabai -m rule --add app="^System Preferences$" sticky=off sub-layer=normal manage=off
      yabai -m rule --add app="^Docker Desktop$" sticky=off sub-layer=normal manage=off
      yabai -m rule --add app="^Karabiner-Elements$" sticky=off sub-layer=normal manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
      yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
    '';
  };

  services.jankyborders = {
    enable = true;
    active_color = "0xff98971a";
    inactive_color = "0xff282828";
    width = 4.0;
  };
}
