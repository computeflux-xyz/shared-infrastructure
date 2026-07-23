# shared-infrastructure

The two infrastructure layers every Computeflux service depends on.

- **`terraform/`** provisions bare metal: a Talos Kubernetes cluster on Hetzner
  (`hcloud/`) and the Hetzner object storage buckets (`s3.tf`). Cloudflare edge
  is per-service, not here (each service has its own `deploy/terraform`).
- **`k8s/`** installs the shared platform on that cluster with Helmfile and Task:
  sealed-secrets, Argo Rollouts and CloudNativePG (foundation). The shared
  Postgres cluster (data), the zot registry, API gateway and Umami analytics
  (platform), the GitHub Actions deployer identity.
- **`.github/workflows/`** hosts the reusable CI workflows that service pipelines
  call (`.check-pipeline-flags`, `.docker-build-push`, `.deploy-k8s`), plus this
  repo's own docs and terraform checks.
- **`docs/`** is a Bikeshed guide, published to GitHub Pages, explaining how the
  two planes relate and how to write per-service deployment logic.

The two planes meet at one artifact: the kubeconfig Terraform emits and the
Kubernetes plane consumes. Read `docs/spec.bs` (or the published guide) for the
full picture.

## Layout

```
terraform/
  hcloud/            Talos-on-Hetzner cluster module
  s3.tf              Hetzner object storage buckets
  kubernetes.tf      cluster configuration
  *.tfstate/*.tfvars/kubeconfig/talosconfig   (git-crypt encrypted)
k8s/
  Taskfile.yaml      bootstrap the layers
  helmfile.yaml.gotmpl
  foundation/ data/ platform/ github-actions/ namespaces/ shared/
docs/
  spec.bs            Bikeshed guide
  diagrams/*.puml    PlantUML sources
.github/workflows/   reusable service workflows + docs + terraform
```

## Quick start

```bash
git-crypt unlock /path/to/keyfile      # decrypt terraform state and creds

task tf:init && task tf:plan
task tf:apply
task tf:kubeconfig

task k8s:deploy:all                    # foundation, data, platform, umami, gha
```

## Secrets

- **git-crypt** encrypts Terraform state and cloud credentials at rest
  (`.gitattributes`).
- **sealed-secrets** encrypts Kubernetes secrets; `*.sealed.yaml` files are safe
  to commit. Create them with `task k8s:seal:secret`.
