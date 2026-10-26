# Security

The webhook holds or reads the Hetzner Cloud API tokens, which can change the DNS records of your zones, so it's hardened following the same practices as the [Kadras cert-manager package](https://github.com/kadras-io/package-for-cert-manager/blob/main/docs/security.md).

## Pod Security Standards

The webhook complies with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), enforced on the namespace by the cert-manager package: it runs as non-root, with a read-only root filesystem, no privilege escalation, no capabilities, and the `RuntimeDefault` seccomp profile.

## Service account token

The service account token isn't auto-mounted. The container mounts a projected token instead, which expires after an hour and is rotated by the kubelet.

## Secrets access

The webhook gets the Secret referenced by an Issuer via `tokenSecretKeyRef` from the namespace of the Issuer, or from the namespace of cert-manager for a ClusterIssuer. It's only granted the `get` verb on Secrets: it can't list or watch them. Where, depends on `security.secrets_access`:

| Value | Secrets the webhook can read | Use it when |
|-------|------------------------------|-------------|
| `cluster` (default) | In all the namespaces | You have Issuers referencing a token Secret in namespaces other than the one of cert-manager |
| `namespace` | In the namespace of cert-manager | You only use ClusterIssuers, like the Let's Encrypt one of the cert-manager package, or Issuers in the namespace of cert-manager |
| `none` | None | All the Issuers read the token via `tokenFilePath` (see [issuers.md](issuers.md#token-from-a-file)) |

Prefer `namespace` or `none` when possible.

```yaml
security:
  secrets_access: namespace
```

## Network policies

The package can deny the inbound traffic to the webhook Pods, except for:

* the requests from the Kubernetes API server, on port 8443, which forwards the DNS-01 challenges sent by cert-manager;
* the metrics scraping, on port 8080.

```yaml
security:
  network_policies: true
```

Enable it when the cert-manager package has `security.network_policies` enabled: that denies all the inbound traffic in the namespace of cert-manager, including to the webhook, which would make its APIService unavailable. The policy of this package only selects the webhook Pods, so it doesn't affect cert-manager.

The source of both is not known in advance, so they're allowed from anywhere. The traffic from the kubelet, like health probes, is always allowed. The outbound traffic isn't restricted, since the webhook reaches the Kubernetes API server and the Hetzner Cloud API (`api.hetzner.cloud`, port 443). Restrict them further with a ytt overlay (see [configuration.md](configuration.md)), for example to only allow scraping from the namespace of Prometheus:

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "NetworkPolicy", "metadata": {"name": "cert-manager-webhook-hetzner"}})
---
spec:
  #@overlay/replace
  ingress:
    - ports:
        - protocol: TCP
          port: 8443
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: observability
      ports:
        - protocol: TCP
          port: 8080
```

## Image signatures

The upstream images aren't signed, so the package doesn't include Kyverno policies verifying them, unlike the cert-manager package. The package itself is signed and comes with a SLSA provenance attestation (see [verify-release.md](verify-release.md)).
