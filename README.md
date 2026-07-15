# Infra

[![Status](https://github.com/majabojarska/infra/actions/workflows/status.yaml/badge.svg)](https://github.com/majabojarska/infra/actions/workflows/status.yaml)

Version control for my homelab's infrastructure and services.

## Repo structure

### `./ansible`

Ansible automates:

- NixOS host configuration deployment.
- Upgrades and maintenance of Proxmox VE hypervisors.

### `./kubernetes`

Contains the sources for the home prod cluster, managed via FluxCD.
Reconciliation (deployment) happens periodically through in-cluster Flux controllers, which bring the cluster up-to-date.

### `./terraform`

Manages the infrastructure, although the configuration might be outdated at the moment.

- DNS records (OVH),
- virtual instance(s) (Linode),

### Nix devenv

Use the repo dev environment for NixOS and deploy tooling (including `deploy-rs`):

```sh
direnv allow
```

Or without direnv:

```sh
nix develop
```

Useful commands available in the shell:

```sh
flake-check   # nix flake check for ./nix
flake-update  # nix flake update for ./nix
deploy-build  # deploy-rs dry activation
deploy-apply  # deploy-rs activation
```

### Deploy a specific NixOS host

This repo's host flake is at `./nix`.
Deploy one host by targeting its `nixosConfigurations.<host>` entry:

```sh
sudo nixos-rebuild switch \
  --flake ./nix#<host>
```

Example:

```sh
sudo nixos-rebuild switch \
  --flake ./nix#kube-01
```

For remote deployment from your workstation:

```sh
nixos-rebuild switch \
  --flake ./nix#<host> \
  --target-host <user>@<host-or-ip> \
  --sudo
```

For remote deployment from your workstation, with remote build:

```sh
nixos-rebuild build \
  --flake ./nix#sp6cat-vm-01 \
  --build-host <user>@<host-or-ip> \
  --target-host <user>@<host-or-ip> \
  --sudo
```
