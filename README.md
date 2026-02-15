# Infra

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

## Development

To run checks locally on every commit:

```sh
pre-commit install
```
