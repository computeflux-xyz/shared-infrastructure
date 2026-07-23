terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.s3_region

  endpoints {
    s3 = "https://${var.s3_region}.your-objectstorage.com"
  }

  access_key                  = var.s3_access_key
  secret_key                  = var.s3_secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  s3_use_path_style = true
}

# Application buckets
resource "aws_s3_bucket" "etcd_backups" {
  bucket = "computeflux-etcd-backups"
}

resource "aws_s3_bucket" "registry" {
  bucket = "computeflux-registry"
}

resource "aws_s3_bucket" "assets" {
  bucket = "computeflux-assets"
}

resource "aws_s3_bucket" "db_backups" {
  bucket = "computeflux-db-backups"
}

resource "aws_s3_bucket" "longhorn_backups" {
  bucket = "computeflux-longhorn-backups"
}

resource "aws_s3_bucket" "loki" {
  bucket = "computeflux-loki"
}