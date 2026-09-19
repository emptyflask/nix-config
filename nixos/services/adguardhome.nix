{lib, ...}: let
  lanZone = domain: ip:
    map (d: {
      domain = d;
      answer = ip;
      enabled = true;
    }) [domain "*.${domain}"];
in {
  services.adguardhome = {
    enable = true;
    port = 8080;
    settings = {
      dns = {
        bind_hosts = ["0.0.0.0"];
        port = 53;
        upstream_dns = ["1.1.1.2" "1.0.0.2"];
        bootstrap_dns = ["1.1.1.1" "1.0.0.1"];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        rewrites =
          lanZone "kepler.lan" "10.9.8.7"
          ++ lanZone "newton.lan" "10.9.8.10"
          ++ lanZone "planck.lan" "10.9.8.6"
          ++ [
            {
              domain = "printer.lan";
              answer = "10.9.8.139";
              enabled = true;
            }
          ];
      };
      filters = lib.imap (i: orig:
        lib.mergeAttrs orig {
          id = i;
          enabled = true;
        }) [
        {
          name = "Main Tier (Pro)";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/pro.txt";
        }
        {
          name = "Threat Intelligence Feeds (Mini)";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/tif.mini.txt";
        }
        {
          name = "Dynamic DNS";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/dyndns.txt";
        }
        {
          name = "Gambling (Mini)";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/gambling.mini.txt";
        }
        {
          name = "Huawei";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.huawei.txt";
        }
        {
          name = "Samsung";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.samsung.txt";
        }
        {
          name = "LG webOS";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.lgwebos.txt";
        }
        {
          name = "Roku";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.roku.txt";
        }
        {
          name = "Vivo";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.vivo.txt";
        }
        {
          name = "OPPO/Realme";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.oppo-realme.txt";
        }
        {
          name = "Xiaomi";
          url = "https://hagezi-mirror.dnsbunker.org/adblock/native.xiaomi.txt";
        }
      ];
      users = [
        {
          name = "admin";
          password = "$2b$05$VfTy4UdB6Q5BRfzX7EFqMOlB2Js8XpGPEz0PQaDXgeZ4SuEdsOcuu";
        }
      ];
    };
  };
}
