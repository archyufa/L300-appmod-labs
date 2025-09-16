#!/bin/bash

# This script enable fleet-level features and configure Policy Controller to enforce security and compliance standards.

# --- Configuration ---
# Ensure these variables are set correctly for your environment.
export PROJECT_ID=$(gcloud config get-value project)
# Variables 
export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"

gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME

# echo "Creating Namespace cymbal-namespace ..."
# kubectl create ns cymbal-namespace
# echo "Namespace cymbal-namespace was created"


# echo "Creating Constraint Template YAML file ..."
# cat <<EOF > constraint.yaml
# apiVersion: templates.gatekeeper.sh/v1beta1
# kind: ConstraintTemplate
# metadata:
#   name: customlabeltemplate
# spec:
#   crd:
#     spec:
#       names:
#         kind: customlabeltemplate
#       validation:
#         openAPIV3Schema:
#           type: object
#           properties:
#             labels:
#               type: array
#               items:
#                 type: object
#                 properties:
#                   key:
#                     type: string
#   targets:
#     - target: admission.k8s.gatekeeper.sh
#       rego: |
#         package k8srequiredlabels
#         violation[{"msg": msg}] {
#           not input.review.object.metadata.labels["environment"]
#           msg := "You must provide the label 'environment: production'"
#         }

#         violation[{"msg": msg}] {
#           input.review.object.metadata.labels["environment"] != "production"
#           msg := "The 'environment' label must be set to 'production'"
#         }
# EOF

# echo "Appling the provided Constraint Template YAML file to the cluster ..."
# kubectl apply -f constraint.yaml


# cat <<EOF > customlabeltemplate.yaml
# apiVersion: constraints.gatekeeper.sh/v1beta1
# kind: customlabeltemplate
# metadata:
#   name: ns-must-have-labels
# spec:
#   match:
#     namespaces:
#     - cymbal-namespace
#     kinds:
#       - apiGroups: [""]
#         kinds: ["Namespace", "Pod"]
#   parameters:
#     labels:
#       - key: "environment"
#         value: "production"
# EOF

# echo "Appling the provided Constraint Template YAML file to the cluster ..."
# kubectl apply -f customlabeltemplate.yaml



cat <<EOF > badlabelpod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
spec:
  securityContext:
    runAsNonRoot: true
  containers:
  - name: simple-container
    image: busybox:latest # A small, common image for demonstration
    command: ["sh", "-c", "echo 'This pod runs with elevated privileges (for demonstration).' && sleep 3600"]
    securityContext:
      runAsUser: 1001
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - "ALL"
EOF

echo "Appling the provided Constraint Template YAML file to the cluster ..."
kubectl apply -f badlabelpod.yaml


