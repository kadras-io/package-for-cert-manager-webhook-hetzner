# Configuring Observability

Monitor and observe the operation of cert-manager-webhook-hetzner using metrics.

## Metrics

Metrics configuration for the cert-manager-webhook-hetzner deployment is enabled by default using the Prometheus format. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from all its components.

If you'd like to remove the Prometheus annotations and therefore disable automatic scraping of cert-manager metrics, you can apply the following configuration:

```yaml
prometheus:
  enabled: false
```
