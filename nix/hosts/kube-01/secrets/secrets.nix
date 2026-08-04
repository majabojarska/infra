let
  developers = import ../../../modules/keys-developers-age.nix;

  # Systems
  kube-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLa2Aq4Zw4RImQ+XHRHxS7gSrKtwan5bEtg6D20k5TT root@nixos";
in
{
  "borgmatic-kubernetes-enc-pass.age".publicKeys = [ kube-01 ] ++ developers;
  "traefik.env.age".publicKeys = [ kube-01 ] ++ developers;
  "ntfy-token.age".publicKeys = [ kube-01 ] ++ developers;
  "immich.env.age".publicKeys = [ kube-01 ] ++ developers;
  "paperless.env.age".publicKeys = [ kube-01 ] ++ developers;
}
