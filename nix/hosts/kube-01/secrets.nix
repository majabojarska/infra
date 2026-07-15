{
  age = {
    secrets = {
      "tailscale-auth-key" = {
        file = ./secrets/tailscale-auth-key.age;
        mode = "0400";
      };
    };
  };
}
