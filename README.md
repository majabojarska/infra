# Infra

[![Status](https://github.com/majabojarska/infra/actions/workflows/status.yaml/badge.svg)](https://github.com/majabojarska/infra/actions/workflows/status.yaml)

Version control for my homelab's infrastructure and services.

## Operations


### Deploy NixOS hosts

For `kube-01`

```sh
nixos-rebuild switch --flake ./nix#kube-01 --target-host maja@kube-01.home.majabojarska.dev --build-host maja@kube-01.home.majabojarska.dev  --sudo
```

### Deploy ansible PVE hosts

Just `sp6cat-01` and `pve-01`:
```sh
# From ./ansible
ansible-playbook pve.yaml --limit=sp6cat-01,pve-01
```
