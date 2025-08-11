{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    # plugins = {
    #   hexyl = builtins.fetchGit {
    #     url = "https://github.com/Reledia/hexyl.yazi";
    #     ref = "main";
    #   };
    #   glow = builtins.fetchGit {
    #     url = "https://github.com/Reledia/glow.yazi";
    #     ref = "main";
    #   };
    #   miller = builtins.fetchGit {
    #     url = "https://github.com/Reledia/miller.yazi";
    #     ref = "main";
    #   };
    # };
    settings = {
      mgr = {
        sort_by = "natural";
        sort_reverse = false;
        sort_dir_first = true;
        show_hidden = false;
        show_symlink = true;
      };
      opener = {
        audio = [{
          run = ''${pkgs.audacious}/bin/audacious "$@"'';
          orphan = true;
        }];
        video = [{
          run = ''${pkgs.mplayer}/bin/mplayer "$@"'';
          orphan = true;
        }];
      };
      open = {
        prepend_rules = [
          {
            mime = "audio/*";
            use = "audio";
          }
          {
            mime = "video/*";
            use = "video";
          }
        ];
      };
      plugin = {
        prepend_previewers = [
          {
            name = "*.md";
            run = "glow";
          }
          {
            mime = "text/csv";
            run = "miller";
          }
        ];
        append_previewers = [{
          name = "*";
          run = "hexyl";
        }];
      };
    };
  };
}
