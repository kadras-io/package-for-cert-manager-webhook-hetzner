# Issuers

The webhook solves the ACME DNS-01 challenges for the Issuers and ClusterIssuers referencing it. For each challenge, cert-manager calls the webhook, which creates a TXT record named `_acme-challenge.<domain>` via the Hetzner Cloud API, and deletes it once the challenge is solved. See the upstream [architecture](https://github.com/hetzner/cert-manager-webhook-hetzner/blob/main/docs/explanation/architecture.md) for the full flow.

## Hetzner Cloud API token

The webhook authenticates with the Hetzner Cloud API with a token. Create it in the [Hetzner Console](https://console.hetzner.com) with read and write permissions, for the project hosting your DNS zone, as described in the [Hetzner documentation](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token).

## The Kadras cert-manager package

The Let's Encrypt ClusterIssuer of the [Kadras cert-manager package](https://github.com/kadras-io/package-for-cert-manager) uses this webhook with the `hetzner` DNS-01 provider. Store the token in a Secret and reference it from the cert-manager package values:

```shell
kubectl create secret generic hetzner-dns -n kadras-system --from-literal=api-token=<HETZNER_TOKEN>
```

```yaml
issuers:
  letsencrypt:
    enabled: true
    environment: production
    email: security@example.com
    solver: dns01
    dns01:
      provider: hetzner
      credentials:
        secret: hetzner-dns
        key: api-token
        namespace: kadras-system
```

The cert-manager package syncs the Secret into its namespace, where the webhook reads it. That's enough for `security.secrets_access: namespace` (see [security.md](security.md#secrets-access)).

## Your own Issuers

Reference the webhook from the DNS-01 solver of an Issuer or ClusterIssuer:

* `groupName`: always `acme.hetzner.kadras.io`, the API group served by the webhook of this package. The upstream documentation uses `acme.hetzner.com`, the default of the upstream Helm chart, which doesn't apply here.
* `solverName`: always `hetzner`.
* `config`: where to read the token from, as described in the [upstream reference](https://github.com/hetzner/cert-manager-webhook-hetzner/blob/main/docs/reference/issuer-configuration.md).

### Token from a Secret

The webhook gets the Secret referenced via `tokenSecretKeyRef` from the namespace of the Issuer, or from the namespace of cert-manager for a ClusterIssuer.

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-hetzner
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: security@example.com
    privateKeySecretRef:
      name: letsencrypt-hetzner
    solvers:
      - dns01:
          webhook:
            groupName: acme.hetzner.kadras.io
            solverName: hetzner
            config:
              tokenSecretKeyRef:
                name: hetzner-dns
                key: api-token
```

### Token from a file

The package can mount the token into the webhook from a Secret in the namespace of cert-manager:

```yaml
token:
  secret: hetzner-dns
  key: api-token
```

Issuers then reference it via `tokenFilePath`, so they don't need a Secret of their own:

```yaml
solvers:
  - dns01:
      webhook:
        groupName: acme.hetzner.kadras.io
        solverName: hetzner
        config:
          tokenFilePath: /var/run/secrets/hetzner/token
```

When all the Issuers use `tokenFilePath`, the webhook doesn't need to read Secrets at all: set `security.secrets_access: none` (see [security.md](security.md#secrets-access)). The Let's Encrypt ClusterIssuer of the Kadras cert-manager package uses `tokenSecretKeyRef`, so it requires `cluster` or `namespace`.
