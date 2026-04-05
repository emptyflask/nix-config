{ den, ... }: {
  den.aspects.shell.homeManager = {
    imports = [
      ../../home-manager/programs/zsh
      ../../home-manager/programs/starship
      ../../home-manager/programs/tmux
      ../../home-manager/programs/vim
    ];
  };
}
