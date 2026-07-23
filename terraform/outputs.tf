output "kubeconfig" {
  value       = module.kubernetes.kubeconfig
  sensitive   = true
  description = "Kubernetes configuration file content"
}

output "talosconfig" {
  value       = module.kubernetes.talosconfig
  sensitive   = true
  description = "Talos configuration file content"
}

output "control_plane_ips" {
  value = {
    public_ipv4  = module.kubernetes.control_plane_public_ipv4_list
    public_ipv6  = module.kubernetes.control_plane_public_ipv6_list
    private_ipv4 = module.kubernetes.control_plane_private_ipv4_list
  }

  description = "Control plane node IP addresses"
}

output "worker_ips" {
  value = {
    public_ipv4  = module.kubernetes.worker_public_ipv4_list
    public_ipv6  = module.kubernetes.worker_public_ipv6_list
    private_ipv4 = module.kubernetes.worker_private_ipv4_list
  }

  description = "Worker node IP addresses"
}

output "kube_api_endpoint" {
  value       = module.kubernetes.kube_api_load_balancer
  description = "Kubernetes API load balancer endpoint"
}

output "s3_buckets" {
  value = {
    etcd_backups     = aws_s3_bucket.etcd_backups.bucket
    registry         = aws_s3_bucket.registry.bucket
    assets           = aws_s3_bucket.assets.bucket
    db_backups       = aws_s3_bucket.db_backups.bucket
    longhorn_backups = aws_s3_bucket.longhorn_backups.bucket
  }

  description = "Created S3 buckets"
}

output "s3_endpoint" {
  value       = "https://${var.s3_region}.your-objectstorage.com"
  description = "S3 endpoint URL"
}

output "longhorn_s3_credentials" {
  value = {
    access_key = var.s3_access_key
    secret_key = var.s3_secret_key
    endpoint   = "https://${var.s3_region}.your-objectstorage.com"
  }

  sensitive   = true
  description = "Credentials for Longhorn S3 backups (using main S3 credentials)"
}