{
  age = {
    secrets = {
      "traefik.env" = {
        file = ./secrets/ovh.age;
        mode = "0400";
      };
      # "nextcloud-admin-pass" = {
      #   file = ./secrets/nextcloud-admin-pass.age;
      #   mode = "0400";
      #   owner = "nextcloud";
      #   group = "nextcloud";
      # };
      "fah-token" = {
        file = ./secrets/fah-token.age;
        mode = "0400";
      };
      "searx-secret-key" = {
        file = ./secrets/searx-secret-key.age;
        mode = "0400";
      };
      "tailscale-auth-key" = {
        file = ./secrets/tailscale-auth-key.age;
        mode = "0400";
      };
    };
  };
}
