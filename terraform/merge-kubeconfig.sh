#!/bin/bash
# merge-kubeconfig.sh - Merge ComputeFlux kubeconfig into main config

set -e

KUBECONFIG_SOURCE="kubeconfig"
KUBECONFIG_MAIN="$HOME/.kube/config"

echo "Merging ComputeFlux kubeconfig"
echo "=================================="
echo ""

if [ ! -f "$KUBECONFIG_SOURCE" ]; then
    echo "Error: $KUBECONFIG_SOURCE not found"
    echo "   Run 'terraform apply' first."
    exit 1
fi

BACKUP="$HOME/.kube/config.backup.$(date +%Y%m%d-%H%M%S)"
echo "Backing up current config to:"
echo "   $BACKUP"
cp "$KUBECONFIG_MAIN" "$BACKUP"
echo ""

echo "Merging configurations..."
KUBECONFIG="$KUBECONFIG_MAIN:$KUBECONFIG_SOURCE" kubectl config view --flatten > /tmp/merged-kubeconfig

mv /tmp/merged-kubeconfig "$KUBECONFIG_MAIN"
chmod 600 "$KUBECONFIG_MAIN"

echo "Configs merged successfully"
echo ""

echo "Available contexts:"
kubectl config get-contexts

echo ""
echo "Done! You can now switch to ComputeFlux:"
echo "   kubectl config use-context admin@computeflux"
echo ""
echo "Your old config was backed up to:"
echo "   $BACKUP"