{ pkgs, ... }:
{
  home = {
    username = "jonroberts";
    homeDirectory = "/Users/jonroberts";
    file = {
      ".ghci".source = ../../home-manager/home/ghci;
      ".psqlrc".source = ../../home-manager/home/psqlrc;
      ".railsrc".source = ../../home-manager/home/railsrc;
    };

    packages = with pkgs; [
      zlib
      # nixFlakes
    ];

    sessionPath = ["$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin"];
  };

  # zathura not in a feature module for gaudi
  imports = [ ../../home-manager/programs/zathura ];

  home.stateVersion = "23.11";
}
