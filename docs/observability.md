# Observability

## Logs

The webhook writes logs in the text format. Set the log level to `debug` to troubleshoot the challenges, or to `warn` or `error` to reduce the volume.

```yaml
observability:
  logging:
    level: debug
```

## Metrics

The webhook exposes metrics in the Prometheus format on port 8080 (`/metrics`), including the requests to the Hetzner Cloud API. Its Pods are annotated for Prometheus scraping. To remove the annotations:

```yaml
observability:
  metrics:
    enabled: false
```

The `cert-manager-webhook-hetzner` Service exposes the metrics too, on the `metrics` port, for a Prometheus Operator ServiceMonitor.
