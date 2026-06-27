let
  developers = import ../../../modules/keys-developers.nix;

  # Systems
  sp6cat-vm-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNo31eqosBfzGo91+3ftgHMvOpKWDE3FPY5L/aw/9X1";
in
{
  "ovh.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "copyparty-pass-maja.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "copyparty-pass-baczek.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "fah-token.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "searx-secret-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "wg-baczek-priv-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
  "wd-usb-hdd-key.age".publicKeys = [ sp6cat-vm-01 ] ++ developers;
}
