#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
# Qwiklabs will give you a region to use in the instructions once the environment is provisioned. Use that region here.
REGION="us-west1" # use Region given to you by qwiklabs


# 0. Create a Fleet
echo "Creating a fleet for the project..."
# This command creates a fleet with the display name 'fleet' if one doesn't exist.
# '|| true' ensures the script doesn't fail if the fleet has already been created.
gcloud container fleet create --display-name="gke-cymbal-fleet" --project=$PROJECT_ID || true


# 1. Create the GKE Autopilot Cluster

# --- Script Execution ---

echo "--- Task 1: Create a GKE Autopilot Cluster ---"
echo ""
echo "Creating GKE Autopilot cluster named '$CLUSTER_NAME' in region '$REGION'..."
echo "This operation can take several minutes to complete."

gcloud container clusters create-auto "$CLUSTER_NAME" \
    --region="$REGION" \
    --fleet-project="$PROJECT_ID" \
    --project="$PROJECT_ID"

# Check the exit code of the gcloud command to confirm success
if [ $? -eq 0 ]; then
    echo ""
    echo "GKE Autopilot cluster '$CLUSTER_NAME' created successfully."
    echo "You can verify its status in the Google Cloud Console or by running:"
    echo "gcloud container clusters list --filter=\"name=$CLUSTER_NAME\""
else
    echo ""
    echo "Error: Failed to create GKE Autopilot cluster '$CLUSTER_NAME'." >&2
    exit 1
fi

echo "GKE Cluster '$CLUSTER_NAME' created and registered to the fleet."
