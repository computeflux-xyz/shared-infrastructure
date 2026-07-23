## Hetzner cloud related
variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API Token"
}

variable "s3_access_key" {
  type        = string
  sensitive   = true
  description = "S3 access key for all S3 operations (backups, buckets, etc.)"
}

variable "s3_secret_key" {
  type        = string
  sensitive   = true
  description = "S3 secret key for all S3 operations (backups, buckets, etc.)"
}

variable "s3_region" {
  type        = string
  default     = "fsn1"
  description = "S3 region (Hetzner location)"
}

variable "talos_backup_age_public_key" {
  type        = string
  default     = null
  description = "AGE public key for backup encryption (optional)"
}
