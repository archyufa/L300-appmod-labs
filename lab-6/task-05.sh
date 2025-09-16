#!/bin/bash

# This script deploy an insecure workload without applying a security policy

# --- Configuration ---
# Ensure these variables are set correctly for your environment.
export PROJECT_ID=$(gcloud config get-value project)

# Variables 
export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"
export NAMESPACE_NAME_1="cymbal-bank-ns"
export NAMESPACE_NAME_2="online-boutique-ns"

# Create a JSON configuration file for fleet logging using the following code:

echo "Creating unsecured pod manifest..."
cat <<EOF > unsecurepod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-insecure-pod-demo
  labels:
    app: insecure-app
spec:
  containers:
  - name: insecure-container
    image: busybox:latest # A small, common image for demonstration
    command: ["sh", "-c", "echo 'This pod runs with elevated privileges (for demonstration).' && sleep 3600"]
    securityContext:
      runAsUser: 0 
      allowPrivilegeEscalation: true 
  restartPolicy: Never
EOF

# Deploy unsecured pod:

gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME
kubectl apply -f unsecurepod.yaml
