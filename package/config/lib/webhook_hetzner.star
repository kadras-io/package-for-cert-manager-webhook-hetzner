# The name of the Deployment, container, Service, and ServiceAccount of the webhook, as rendered from the upstream Helm chart.
name = "cert-manager-webhook-hetzner"

# The namespace the upstream Helm chart is rendered into (see `task vendor`), replaced by the package namespace.
upstream_namespace = "cert-manager"

# The ports of the webhook server, called by the Kubernetes API server, and of the metrics server.
https_port = 8443
metrics_port = 8080

# The directory where the Hetzner Cloud API token is mounted, if `token.secret` is set.
token_directory = "/var/run/secrets/hetzner"

# The labels selecting the webhook Pods, as defined in the upstream Helm chart.
def selector():
  return {
    "app": name,
    "release": name,
  }
end
