{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = [
      pkgs.gutenprint
      pkgs.hplip # if HP
      pkgs.foomatic-filters
    ];
  };

  environment.systemPackages = with pkgs; [
    ghostscript
    cups-filters
    poppler-utils
  ];
}
