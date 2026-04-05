{ den, ... }: {
  den.aspects.mail.homeManager = {
    imports = [
      ../../home-manager/programs/neomutt
      ../../home-manager/accounts
    ];
  };
}
