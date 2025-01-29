#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting Kustomize Manifest Validation..."

# Install Kustomize if not available
if ! command -v kustomize &> /dev/null; then
  echo "⚡ Installing Kustomize..."
  curl -LO "https://github.com/kubernetes-sigs/kustomize/releases/latest/download/kustomize-linux-amd64"
  chmod +x kustomize-linux-amd64
  sudo mv kustomize-linux-amd64 /usr/local/bin/kustomize
fi

# Install kubeconform if not available
if ! command -v kubeconform &> /dev/null; then
  echo "⚡ Installing kubeconform..."
  curl -L -o kubeconform https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64
  chmod +x kubeconform
  sudo mv kubeconform /usr/local/bin/
fi

# Validate each overlay
for overlay in k8s/overlays/*; do
  if [ -d "$overlay" ]; then
    echo "🔍 Validating overlay: $overlay"
    
    # Validate with kubectl dry-run
    kustomize build "$overlay" | kubectl apply --dry-run=client -f -
    
    # Validate with kubeconform
    kustomize build "$overlay" | kubeconform -strict -summary -schema-location default
  fi
done

echo "✅ All Kustomize manifests validated successfully!"

