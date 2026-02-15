let
  # Developers
  maja = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com";
  developers = [ maja ];

  # Systems
  kube-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLa2Aq4Zw4RImQ+XHRHxS7gSrKtwan5bEtg6D20k5TT root@nixos";
in
{
  "tailscale-auth-key.age".publicKeys = [ kube-01 ] ++ developers;
  "borgmatic-kubernetes-enc-pass.age".publicKeys = [ kube-01 ] ++ developers;
}

