{ den, lib, ... }: {
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.includes = [ den.provides.mutual-provider ];
}
