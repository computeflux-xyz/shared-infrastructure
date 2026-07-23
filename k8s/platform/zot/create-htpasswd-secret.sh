#!/bin/bash
set -e

echo "Creating htpasswd secret for Zot..."

USERNAME=$(kubectl get secret -n platform zot-registry-auth -o jsonpath='{.data.username}' | base64 -d)
PASSWORD=$(kubectl get secret -n platform zot-registry-auth -o jsonpath='{.data.password}' | base64 -d)
HTPASSWD_ENTRY=$(htpasswd -nbB "$USERNAME" "$PASSWORD")

kubectl create secret generic zot-htpasswd \
  -n platform \
  --from-literal=htpasswd="$HTPASSWD_ENTRY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "htpasswd secret created"