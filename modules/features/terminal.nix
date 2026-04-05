{ den, ... }: {
  den.aspects.terminal.homeManager = {
    imports = [
      ../../home-manager/programs/kitty
      ../../home-manager/programs/alacritty
    ];
  };
}
