# Terraform

Provisions the bare-metal substrate:

- `hcloud/` - Talos Kubernetes cluster on Hetzner (nodes, Cilium, ingress-nginx,
  cert-manager, storage, metrics). Wired up in `kubernetes.tf`.
- `s3.tf` - Hetzner object storage buckets (backups, registry, assets).

Cloudflare edge resources are not here. They are per-service and live in each
service's own `deploy/terraform` (for example
`agency/services/site/deploy/terraform`).

## Run

```bash
terraform init
terraform plan
terraform apply
./merge-kubeconfig.sh
```

## State and secrets

Local state is committed and encrypted with git-crypt, along with
`terraform.tfvars`, `kubeconfig` and `talosconfig` (see `../.gitattributes`).
Unlock with `git-crypt unlock <keyfile>` before running Terraform.

Credentials that are not in `terraform.tfvars` (`s3_access_key`, `s3_secret_key`)
are supplied at run time through `TF_VAR_*` environment variables.

## Outputs

```bash
terraform output s3_buckets                  # created buckets
terraform output kube_api_endpoint           # Kubernetes API load balancer
terraform output -raw kubeconfig > kubeconfig
```
