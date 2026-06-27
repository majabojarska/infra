{
  age = {
    secrets = {
      "traefik.env" = {
        file = ./secrets/ovh.age;
        mode = "0400";
      };
      "copyparty-pass-maja" = {
        file = ./secrets/copyparty-pass-maja.age;
        mode = "0400";
        owner = "copyparty";
        group = "copyparty";
      };
      "copyparty-pass-baczek" = {
        file = ./secrets/copyparty-pass-baczek.age;
        mode = "0400";
        owner = "copyparty";
        group = "copyparty";
      };
      "fah-token" = {
        file = ./secrets/fah-token.age;
        mode = "0400";
      };
      "searx-secret-key" = {
        file = ./secrets/searx-secret-key.age;
        mode = "0400";
      };
      "wg-baczek-priv-key" = {
        file = ./secrets/wg-baczek-priv-key.age;
        mode = "0400";
        owner = "root";
        group = "root";
      };
      "wd-usb-hdd-key" = {
        file = ./secrets/wd-usb-hdd-key.age;
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };
}
