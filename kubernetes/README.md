# Kubernetes

Kubernetes clusters in this infra are managed through FluxCD.

To re-bootstrap home prod, create a [GitHub PAT](https://fluxcd.io/flux/installation/bootstrap/github/#github-pat:~:text=GitHub%20fine%2Dgrained%20PAT) and run:

```sh
export KUBECONFIG=path/to/kubeconfig.yaml
flux bootstrap github --owner=majabojarska --repository=infra --branch=main --path=./kubernetes/fluxcd/clusters/prod --personal=true --reconcile

# Will prompt for GitHub PAT
```
