# !/bin/bash
PROJECT_ID=$(gcloud config get-value project)

# Variables
export REPO_NAME="container-repo"
export REGION="us-east1"

# 1. Create Artifact Registry repository
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create $REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --immutable-tags \
    --project=$PROJECT_ID
