{ }:
{
  # TODO: Deploy searx
  age.secrets = {
    "searx-secret-key" = {
      file = ../../secrets/searx-secret-key.age;
      mode = "0400";
    };
  };
}
