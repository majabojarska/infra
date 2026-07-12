let
  developers = import ../../../modules/keys-developers.nix;

  # Systems
  sp6cat-vm-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNo31eqosBfzGo91+3ftgHMvOpKWDE3FPY5L/aw/9X1";
in
{
  "traefik.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "copyparty-pass-maja.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "copyparty-pass-baczek.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "searx-env.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "wg-baczek-priv-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "wg-beehive-priv-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "wd-usb-hdd-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "anubis-allow-bearer-token.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "grafana-secret-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "grafana-admin-password.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "telegram-bot-token.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "ntfy-auth.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
}
