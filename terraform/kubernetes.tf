module "kubernetes" {
  source = "./hcloud"

  # Cluster Configuration
  cluster_name   = "computeflux"
  cluster_domain = "cluster.computeflux.local"

  cluster_kubeconfig_path  = "kubeconfig"
  cluster_talosconfig_path = "talosconfig"

  # Network Configuration
  cluster_access            = "public"
  firewall_use_current_ipv4 = true
  firewall_use_current_ipv6 = true
  network_ipv4_cidr         = "10.0.0.0/16"

  # Hetzner Cloud Token
  hcloud_token = var.hcloud_token

  # Control plane: 1 node (not HA for now)
  # Using CPX22 (2 vCPU, 4GB RAM, 80GB SSD) @ €6.49/month each
  control_plane_nodepools = [
    {
      name     = "control"
      type     = "cpx22"
      location = "fsn1"
      count    = 1
      labels = {
        "node-role.kubernetes.io/control-plane" = ""
      }
    }
  ]

  # Worker nodes: 3 nodes for workloads (€32.97/month)
  # Using CPX32 (4 vCPU, 8GB RAM, 160GB SSD) @ €10.99/month each
  # This gives you 12 vCPU and 24GB RAM total for workloads
  worker_nodepools = [
    {
      name            = "worker"
      type            = "cpx32"
      location        = "fsn1"
      count           = 3
      placement_group = true
      labels = {
        "node-role.kubernetes.io/worker" = ""
        "workload.kubernetes.io/type"    = "general"
      }
    }
  ]

  # Kubernetes & Talos Versions
  kubernetes_version = "v1.33.4"
  talos_version      = "v1.11.1"

  # Talos Network Configuration
  talos_public_ipv4_enabled = true
  talos_public_ipv6_enabled = true
  talos_ipv6_enabled        = true

  # Talos Security
  talos_state_partition_encryption_enabled     = true
  talos_ephemeral_partition_encryption_enabled = true

  talos_backup_s3_enabled = true
  talos_backup_s3_hcloud_url = join(".", [
    "https://${aws_s3_bucket.etcd_backups.bucket}",
    "${var.s3_region}",
    "your-objectstorage.com"
  ])
  talos_backup_s3_access_key         = var.s3_access_key
  talos_backup_s3_secret_key         = var.s3_secret_key
  talos_backup_schedule              = "0 2 * * *"
  talos_backup_age_x25519_public_key = var.talos_backup_age_public_key
  talos_backup_enable_compression    = true

  # Cilium CNI Configuration
  cilium_enabled                 = true
  cilium_encryption_enabled      = true
  cilium_encryption_type         = "ipsec"
  cilium_ipsec_algorithm         = "rfc4106(gcm(aes))"
  cilium_ipsec_key_size          = 256
  cilium_routing_mode            = "native"
  cilium_egress_gateway_enabled  = false
  cilium_service_monitor_enabled = true
  cilium_hubble_enabled          = true
  cilium_hubble_relay_enabled    = true
  cilium_hubble_ui_enabled       = true

  # Hetzner Cloud Controller Manager
  hcloud_ccm_enabled                = true
  hcloud_ccm_load_balancers_enabled = true
  hcloud_ccm_network_routes_enabled = true

  # Hetzner Cloud CSI
  hcloud_csi_enabled = true
  hcloud_csi_storage_classes = [
    {
      name                = "hcloud-volumes"
      encrypted           = false
      defaultStorageClass = false
    },
    {
      name                = "hcloud-volumes-encrypted"
      encrypted           = true
      defaultStorageClass = false
      reclaimPolicy       = "Retain"
    }
  ]

  longhorn_enabled               = true
  longhorn_default_storage_class = true
  longhorn_helm_values = {
    defaultSettings = {
      backupTarget                 = "s3://${aws_s3_bucket.longhorn_backups.bucket}@${var.s3_region}/" # Changed
      backupTargetCredentialSecret = "longhorn-s3-secret"
      defaultReplicaCount          = "2"
      guaranteedInstanceManagerCpu = "5"
    }
    persistence = {
      defaultClassReplicaCount = "2"
    }
  }

  # Metrics Server
  metrics_server_enabled                   = true
  metrics_server_schedule_on_control_plane = false
  metrics_server_replicas                  = 2

  # Cert Manager
  cert_manager_enabled = true

  # Ingress NGINX
  ingress_nginx_enabled                         = true
  ingress_nginx_kind                            = "DaemonSet"
  ingress_nginx_topology_aware_routing          = true
  ingress_nginx_service_external_traffic_policy = "Local"

  # Ingress Load Balancer
  ingress_load_balancer_type                   = "lb11"
  ingress_load_balancer_algorithm              = "least_connections"
  ingress_load_balancer_public_network_enabled = true

  # Prometheus Operator CRDs
  prometheus_operator_crds_enabled = true

  # Kubernetes API Load Balancer
  kube_api_load_balancer_enabled                = true
  kube_api_load_balancer_public_network_enabled = true

  # Firewall Rules
  firewall_extra_rules = [
    {
      description = "WireGuard VPN"
      direction   = "in"
      source_ips  = ["0.0.0.0/0", "::/0"]
      protocol    = "udp"
      port        = "51820"
    },
    {
      description = "Temporal gRPC"
      direction   = "in"
      source_ips  = ["0.0.0.0/0", "::/0"]
      protocol    = "tcp"
      port        = "7233"
    }
  ]

  # Talos Discovery
  talos_discovery_kubernetes_enabled = false
  talos_discovery_service_enabled    = true

  # Cluster Management
  cluster_healthcheck_enabled = true
  cluster_graceful_destroy    = true
  cluster_delete_protection   = true

  # RBAC Configuration
  rbac_cluster_roles = [
    {
      name = "admin-viewer"
      rules = [
        {
          api_groups = ["*"]
          resources  = ["*"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
  ]
}