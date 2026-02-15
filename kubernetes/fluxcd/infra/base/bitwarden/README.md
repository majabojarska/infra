# Bitwarden

Needs also this secret.

```bash
kubectl create secret generic bitwarden -n bitwarden
```

```yaml
apiVersion: v1
stringData:
  BW_HOST: "changeme.bitwarden.eu"
  BW_USERNAME: "changeme@example.com"
  BW_PASSWORD: "MasterPassword"
  BW_CLIENTID: "user.CHANGE-ME"
  BW_CLIENTSECRET: "ClientSecret"
kind: Secret
metadata:
  name: bitwarden
  namespace: bitwarden
type: Opaque
```
