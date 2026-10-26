# Corporate Proxy

When running the webhook behind a corporate proxy, configure it to reach the Hetzner Cloud API (`api.hetzner.cloud`) through it.

```yaml
proxy:
  https_proxy: http://proxy.example.com:3128
  no_proxy: .svc,.cluster.local,10.0.0.0/8
```

The webhook also talks to the Kubernetes API server, so include its address in `no_proxy`, together with the Pod and Service networks, so that the cluster traffic doesn't go through the proxy.
