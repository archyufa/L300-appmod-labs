#!/bin/bash

# This script enable fleet-level features and configure Policy Controller to enforce security and compliance standards.

# --- Configuration ---
# Ensure these variables are set correctly for your environment.
export PROJECT_ID=$(gcloud config get-value project)
# Variables 
export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"


# 1. Enable managed Cloud Service Mesh as a default configuration for your fleet
echo "Creating Configuration YAML for Mesh..."
echo "management: automatic" > mesh.yaml

# 2. Apply the Configuration:
echo "Enable Service Mesh for fleet ..."
gcloud container fleet mesh enable \
  --fleet-default-member-config=mesh.yaml
  --project="$PROJECT_ID"

# 3. Enable Policy Controller on the fleet membership

echo "Enabling Policy Controller feature on the fleet membership..."
gcloud beta container fleet policycontroller enable \
    --memberships="$MEMBERSHIP_NAME" \
    --project="$PROJECT_ID"
echo "Policy Controller enabled."
echo ""

# 4. Enable the Pod Security Standards Restricted v2022 policy bundle with enforcement set to deny. 
 
gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME
echo "Enabling pssr v2022..."
echo "Downloading the Pod Security Standards (PSS) Restricted v2022 policy bundle ..."
kpt pkg get https://github.com/GoogleCloudPlatform/gke-policy-library.git/anthos-bundles/pss-restricted-v2022

echo "Run the set-enforcement-action kpt function to set the policies' enforcement action to deny"
kpt fn eval pss-restricted-v2022 -i gcr.io/kpt-fn/set-enforcement-action:v0.1 \
  -- enforcementAction=deny

echo "Initialize the working directory with kpt, which creates a resource to track changes:"
cd pss-restricted-v2022
kpt live init
echo "Initialized kpt ..."


echo "Appling the policy constraints with kpt..."
kpt live apply
echo "Applied the policy constraints with kpt..."


# 5. Redeploy the POD YAML file to test the policy's effectiveness.

echo "Redeploying the POD YAML file to test the policy's effectiveness ..."
gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME
kubectl apply -f unsecurepod.yaml
