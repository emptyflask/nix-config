{ pkgs, ... }:

{
  home.sessionVariables = {
    _JAVA_AWT_WM_NONREPARENTING = 1;

    ACK_COLOR_MATCH = "red";
    EDITOR = "nvim";
    JIRA_API_TOKEN =
      "ATATT3xFfGF03zybKEkJUD1PYKYPhaoLPkIbSZHmwyxax3fZPH4REqmReGOK1GS2GtXGOu70Qmt9uVYFQ3cNOJR5gypntm6vhylsjZYBBNxzXNV2Y4DI6Q1ocHfWSTra70iQW1K098WFNRHUQZ5MY4iFmW-Ty6kWJv_K2zpY5hznt4SPD47u51A=13278F94";
    LESS = "-F -R -M -i";
    LESSOPEN = "| ${pkgs.sourceHighlight}/bin/src-hilite-lesspipe.sh %s";
    MANPAGER = "nvim +Man!";
    PAGER = "${pkgs.less}/bin/less";

    # xz should use all available cores
    XZ_DEFAULTS = "-T 0";
  };
}
