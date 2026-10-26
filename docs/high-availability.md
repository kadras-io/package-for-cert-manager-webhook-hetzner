# High Availability

The webhook is active/active: all replicas serve the requests from the Kubernetes API server, which forwards the DNS-01 challenges sent by cert-manager. Run at least 2 replicas in production.

```yaml
webhook:
  replicas: 2
```

With more than one replica:

* a PodDisruptionBudget keeps at least one replica available during voluntary disruptions, like node drains;
* the replicas are spread across nodes on a best-effort basis, so that single-node clusters keep working.

The webhook runs with the `system-cluster-critical` priority. It serves an aggregated API (`acme.hetzner.kadras.io`): when the APIService is unavailable, the API discovery fails, which blocks the deletion of namespaces and the garbage collection in the cluster.

It requests `10m` CPU and `32Mi` memory, with no limits. To change them, use a ytt overlay (see [configuration.md](configuration.md#resources)).
