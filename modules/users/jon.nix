{ den, ... }: {
  den.aspects.jon = {
    provides.kepler = {
      homeManager = { imports = [ ../hosts/_kepler-home.nix ]; };
      includes = [
        den.aspects.common
        den.aspects.environment
        den.aspects.git
        den.aspects.shell
        den.aspects.editor
        den.aspects.terminal
        den.aspects.desktop
        den.aspects.music
        den.aspects.mail
      ];
    };

    provides.gaudi = {
      homeManager = { imports = [ ../hosts/_gaudi-home.nix ]; };
      includes = [
        den.aspects.git
        den.aspects.shell
        den.aspects.editor
        den.aspects.terminal
        den.aspects.mail
      ];
    };

    provides.newton = {
      homeManager = { imports = [ ../hosts/_newton-home.nix ]; };
      includes = [
        den.aspects.common
        den.aspects.environment
        den.aspects.git
        den.aspects.shell
        den.aspects.editor
        den.aspects.terminal
      ];
    };

    provides.planck = {
      homeManager = { imports = [ ../hosts/_planck-home.nix ]; };
      includes = [
        den.aspects.environment
        den.aspects.git
        den.aspects.shell
        den.aspects.editor-minimal
      ];
    };
  };
}
