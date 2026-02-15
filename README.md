# cert-manager-webhook-hetzner

![Test Workflow](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [cert-manager-webhook-hetzner](https://github.com/hetzner/cert-manager-webhook-hetzner), a webhook that creates the necessary DNS entries in the Hetzner DNS API to solve a DNS01 challenge for a cert-manager Issuer of the ACME type.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.33+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Dependencies

cert-manager-webhook-hetzner requires [cert-manager](https://github.com/kadras-io/package-for-cert-manager). You can install it from the [Kadras package repository](https://github.com/kadras-io/kadras-packages).


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
>   ```shell
>   kctrl package available list -p cert-manager-webhook-hetzner.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to cert-manager-webhook-hetzner, check out [github.com/hetzner/cert-manager-webhook-hetzner](https://github.com/hetzner/cert-manager-webhook-hetzner).

## 🎯&nbsp; Configuration

The cert-manager-webhook-hetzner package can be customized via a `values.yml` file.

  ```yaml
  webhook:
    replicas: 3
  ```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

  ```shell
  kctrl package install -i cert-manager-webhook-hetzner \
    -p cert-manager-webhook-hetzner.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system \
    --values-file values.yml
  ```

### Values

The cert-manager-webhook-hetzner package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|-------|-------------------|-------------|
| `webhook.replicas` | `1` | The number of replicas. In order to enable high availability, at least 3 replicas are recommended. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
