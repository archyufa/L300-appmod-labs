#!/bin/bash

# This script outlines the steps to configure Policy Controller and Config Sync
# and test Anthos Config Management capabilities.  It includes verification
# steps where possible, but some actions require manual configuration in the
# Google Cloud Console.
# This script configures Policy Controller and Config Sync using gcloud and kubectl,
# and tests the Anthos Config Management capabilities.

# Variables (Update these with your actual values)
# --- Configuration ---

PROJECT_ID=$(gcloud config get-value project)
# Qwiklabs will give you a zone to use in the instructions once the environment is provisioned. Use that zone here.

# 1. Enable required APIs
echo "Step 1: Enabling GKE APIs..."
gcloud services enable --project="$PROJECT_ID" \
   container.googleapis.com \
   connectgateway.googleapis.com \
   gkeconnect.googleapis.com \
   gkehub.googleapis.com \
   cloudresourcemanager.googleapis.com \
   iam.googleapis.com

echo "API enabled."
echo ""

# 2. Enable the Config Management feature on the fleet
# echo "Step 2: Enabling Config Management feature on the fleet..."
# gcloud beta container fleet config-management enable --project="$PROJECT_ID"
# echo "Config Management feature enabled."
# echo ""


# Task 2
# Set up teams for fleet
CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
REGION="us-west1" # use Zone given to you by qwiklabs
SCOPE_NAME_1="cymbal-bank-dev-team"
SCOPE_NAME_2="online-boutique-dev-team"
NAMESPACE_NAME_1="cymbal-bank-ns"
NAMESPACE_NAME_2="online-boutique-ns"
MEMBERSHIP_NAME="${CLUSTER_NAME}"
BINDING_NAME_1="${MEMBERSHIP_NAME}-${SCOPE_NAME_1}"
BINDING_NAME_2="${MEMBERSHIP_NAME}-${SCOPE_NAME_2}"
# Qwiklabs will give you a User to use in the instructions once the environment is provisioned. Use that User here.
TEAM_EMAIL_1="student-02-0871da99f4d9@qwiklabs.net"
TEAM_EMAIL_2="student-02-1eed2a7161ce@qwiklabs.net" 
ROLE_1="admin"
ROLE_2="edit"

echo "Task 2: Create a team scope 1 ..."
gcloud container fleet scopes create "$SCOPE_NAME_1"

echo "Task 2: Create a team scope 2 ..."
gcloud container fleet scopes create "$SCOPE_NAME_2"

echo "Task 2: Add cluster to a cymbal-bank-dev-team team scope ..."
gcloud container fleet memberships bindings create "$BINDING_NAME_1" \
  --membership "$MEMBERSHIP_NAME" \
  --location="$REGION" \
  --scope  "$SCOPE_NAME_1"

echo "Task 2: Add cluster to a online-boutique-dev-team team scope ..."
gcloud container fleet memberships bindings create "$BINDING_NAME_2" \
  --membership "$MEMBERSHIP_NAME" \
  --location="$REGION" \
  --scope  "$SCOPE_NAME_2"

echo "Task 2: Create fleet cymbal-bank-ns namespaces ..."
gcloud container fleet scopes namespaces create $NAMESPACE_NAME_1 --scope="$SCOPE_NAME_1"

echo "Task 2: Create fleet online-boutique-ns namespaces ..."
gcloud container fleet scopes namespaces create $NAMESPACE_NAME_2 --scope="$SCOPE_NAME_2"

echo "Task 2: Grant team members N1 access to the team scope N1 ..."

gcloud beta container fleet scopes add-app-operator-binding "$SCOPE_NAME_1" \
  --role="$ROLE_1" \
  --user="$TEAM_EMAIL_1" \
  --project "$PROJECT_ID"

echo "Task 2: Grant team members N2 access to the team scope N2 ..."

gcloud beta container fleet scopes add-app-operator-binding "$SCOPE_NAME_2" \
  --role="$ROLE_2" \
  --user="$TEAM_EMAIL_2" \
  --project "$PROJECT_ID"