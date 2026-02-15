# Configuring High Availability

High availability for cert-manager-webhook-hetzner can be enabled by configuring at least 2 replicas. In that case, a `PodDisruptionBudget` is automatically created to prevent downtime during node unavailability.

```yaml
webhook:
  replicas: 3
```
