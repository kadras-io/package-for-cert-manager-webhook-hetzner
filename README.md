# cert-manager-webhook-hetzner

![Test Workflow](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [cert-manager-webhook-hetzner](https://github.com/hetzner/cert-manager-webhook-hetzner), a cert-manager webhook that solves the ACME DNS-01 challenges by creating TXT records via the Hetzner Cloud API. It lets cert-manager issue certificates from ACME servers like Let's Encrypt for domains hosted on Hetzner DNS, including wildcard certificates.

## ✨&nbsp; What's Included

* **DNS-01 solver**. The webhook serving the `acme.hetzner.kadras.io` API group, used by the Let's Encrypt ClusterIssuer of the [Kadras cert-manager package](https://github.com/kadras-io/package-for-cert-manager) with the `hetzner` DNS-01 provider, and by your own Issuers.
* **High availability**. Configurable replicas, protected by a PodDisruptionBudget and spread across nodes, running with the `system-cluster-critical` priority.
* **Observability**. Configurable log level and Prometheus metrics.
* **Security**. The webhook complies with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), runs with a read-only root filesystem and a short-lived service account token, can be isolated with a network policy, and its access to Secrets can be restricted to its namespace or removed.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### Dependencies

cert-manager-webhook-hetzner requires [cert-manager](https://github.com/kadras-io/package-for-cert-manager). The webhook is deployed in its namespace. You can install it from the [Kadras package repository](https://github.com/kadras-io/kadras-packages).

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

```shell
kctrl package repository add -r kadras-packages \
  --url ghcr.io/kadras-io/kadras-packages \
  -n kadras-system --create-namespace
```

<details><summary>Installation without package repository</summary>
The recommended way of installing the cert-manager-webhook-hetzner package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

```shell
kubectl create namespace kadras-system
kapp deploy -a cert-manager-webhook-hetzner-package -n kadras-system -y \
  -f https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/releases/latest/download/metadata.yml \
  -f https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/releases/latest/download/package.yml
```
</details>

Install the cert-manager-webhook-hetzner package:

```shell
kctrl package install -i cert-manager-webhook-hetzner \
  -p cert-manager-webhook-hetzner.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system
```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
> ```shell
> kctrl package available list -p cert-manager-webhook-hetzner.packages.kadras.io -n kadras-system
> ```

Verify the installed packages and their status:

```shell
kctrl package installed list -n kadras-system
```

### Try It Out

Create a [Hetzner Cloud API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token) with read and write permissions for the project hosting your DNS zone, and store it in a Secret:

```shell
kubectl create secret generic hetzner-dns -n kadras-system --from-literal=api-token=<HETZNER_TOKEN>
```

Configure the Let's Encrypt ClusterIssuer of the cert-manager package to solve the DNS-01 challenges with Hetzner, then update the cert-manager package with these values:

```yaml
issuers:
  letsencrypt:
    enabled: true
    environment: staging
    solver: dns01
    dns01:
      provider: hetzner
      credentials:
        secret: hetzner-dns
        key: api-token
        namespace: kadras-system
```

Issue a wildcard certificate for your domain:

```shell
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: hello
spec:
  secretName: hello-tls
  dnsNames:
    - "*.example.com"
  issuerRef:
    name: letsencrypt-staging-issuer
    kind: ClusterIssuer
EOF
```

Check that the certificate is ready. It's stored in the `hello-tls` Secret.

```shell
kubectl get certificate hello
```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to cert-manager-webhook-hetzner, check out [github.com/hetzner/cert-manager-webhook-hetzner](https://github.com/hetzner/cert-manager-webhook-hetzner/tree/main/docs).

Features:

* [Issuers](docs/issuers.md)
* [High availability](docs/high-availability.md)
* [Observability](docs/observability.md)
* [Security](docs/security.md)

Operations:

* [Configuration and ytt overlays](docs/configuration.md)
* [Corporate proxy](docs/corporate-proxy.md)
* [Upgrading](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The cert-manager-webhook-hetzner package can be customized via a `values.yml` file.

```yaml
webhook:
  replicas: 2
security:
  secrets_access: namespace
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i cert-manager-webhook-hetzner \
  -p cert-manager-webhook-hetzner.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Anything not covered by the values can be customized via ytt overlays, as described in [docs/configuration.md](docs/configuration.md).

### Values

The cert-manager-webhook-hetzner package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `"cert-manager"` | The namespace where cert-manager is installed. The webhook is deployed there too, and it allows the cert-manager ServiceAccount there to send it the DNS-01 challenges. The namespace isn't created by the package. |
| `webhook.replicas` | `1` | The number of webhook replicas. All replicas serve the requests from the Kubernetes API server: 2 are recommended for production. With more than 1 replica, a PodDisruptionBudget is created. |
| `token.secret` | `""` | The name of the Secret, in the package namespace. |
| `token.key` | `"token"` | The key in the Secret holding the token. |
| `observability.logging.level` | `"info"` | The log level. |
| `observability.metrics.enabled` | `true` | Whether to annotate the Pods for Prometheus scraping. The webhook exposes metrics on port 8080. |
| `security.secrets_access` | `"cluster"` | Where the webhook can read the Secrets referenced by Issuers via `tokenSecretKeyRef`: `cluster` for Issuers in any namespace; `namespace` for ClusterIssuers and the Issuers in the package namespace only, which is enough for the Let's Encrypt ClusterIssuer of the cert-manager package; `none` when all Issuers use `tokenFilePath`. |
| `security.network_policies` | `false` | Whether to deny the inbound traffic to the webhook Pods, except for the requests from the Kubernetes API server and the metrics scraping. Enable it when the cert-manager package has `security.network_policies` enabled, since that denies all the inbound traffic in its namespace. |
| `proxy.http_proxy` | `""` | The proxy for HTTP traffic. |
| `proxy.https_proxy` | `""` | The proxy for HTTPS traffic. |
| `proxy.no_proxy` | `""` | A comma-separated list of hostnames, IP addresses, or IP ranges in CIDR format that should not use the proxy. It should include the address of the Kubernetes API server. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Vendor a new version of the upstream Helm chart (set in package/vendir.yml) and render it into the package.
task vendor

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The upstream Helm chart is rendered at vendoring time into `package/config/upstream`, with the values fixed for the package in `package/helm/values.yml`. The configurable values are applied on top via ytt overlays, so the package is rendered with ytt only. The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
