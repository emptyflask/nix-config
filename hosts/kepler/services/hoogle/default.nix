{ ... }:

{
  services.hoogle = {
    enable = true;
    port = 6800;
    packages = hp:
      with hp; [
        aeson
        hscolour
        hspec
        lens
        lens-aeson
        megaparsec
        pretty-show
        QuickCheck
        quickcheck-instances
        test-invariant
        vector
      ];
  };
}
