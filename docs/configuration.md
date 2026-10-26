# Configuration

Anything not covered by the package values can be customized with a [ytt overlay](https://carvel.dev/ytt/docs/latest/ytt-overlays/), stored in a Secret and referenced from the PackageInstall via the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.0` annotation.

```shell
kubectl create secret generic cert-manager-webhook-hetzner-overlays -n kadras-system --from-file=overlays.yml
kubectl annotate packageinstall cert-manager-webhook-hetzner -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=cert-manager-webhook-hetzner-overlays
```

## Resources

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "cert-manager-webhook-hetzner"}})
---
spec:
  template:
    spec:
      containers:
        #@overlay/match by="name"
        - name: cert-manager-webhook-hetzner
          #@overlay/match-child-defaults missing_ok=True
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              memory: 128Mi
```

## Node placement

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "cert-manager-webhook-hetzner"}})
---
spec:
  template:
    spec:
      #@overlay/match-child-defaults missing_ok=True
      nodeSelector:
        node-restriction.kubernetes.io/reserved-for: platform
      #@overlay/match missing_ok=True
      tolerations:
        - key: node-restriction.kubernetes.io/reserved-for
          operator: Equal
          value: platform
          effect: NoExecute
```
