{
  age = {
    secrets = {
      "tailscale-auth-key" = {
        file = ./secrets/tailscale-auth-key.age;
        mode = "0400";
      };
      "borgmatic-kubernetes-enc-pass" = {
        file = ./secrets/borgmatic-kubernetes-enc-pass.age;
        mode = "0400";
      };
    };
  };
}

