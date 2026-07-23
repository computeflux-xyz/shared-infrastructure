#!/bin/bash
set -e

NAMESPACE="github-actions"
SERVICE_ACCOUNT="github-deployer"
SECRET_NAME="github-deployer-token"

TOKEN=$(kubectl get secret -n ${NAMESPACE} ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 -d)
CA_CERT=$(kubectl get secret -n ${NAMESPACE} ${SECRET_NAME} -o jsonpath='{.data.ca\.crt}')
API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')

cat << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${API_SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    namespace: default
    user: ${SERVICE_ACCOUNT}
  name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${TOKEN}
EOF