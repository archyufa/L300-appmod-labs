#!/bin/bash

# This script deploys applications to the teams

# --- Configuration ---
# Ensure these variables are set correctly for your environment.
export PROJECT_ID=$(gcloud config get-value project)

# Variables 
export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"
export NAMESPACE_NAME_1="cymbal-bank-ns"
export NAMESPACE_NAME_2="online-boutique-ns"

# Clone the Bank of Anthos repository
echo "Cloning Bank of Anthos repository..."
if [ -d "bank-of-anthos" ]; then
    echo "Bank of Anthos directory already exists. Skipping clone."
else
    git clone https://github.com/GoogleCloudPlatform/bank-of-anthos.git || { echo "ERROR: Failed to clone repository. Exiting."; exit 1; }
fi

BOA_DIR="bank-of-anthos"
if [ ! -d "$BOA_DIR" ]; then
    echo "ERROR: Expected directory '$BOA_DIR' not found after cloning. Exiting."
    exit 1
fi

cd "$BOA_DIR" || { echo "ERROR: Failed to change directory to $BOA_DIR. Exiting."; exit 1; }

# Deploy the Cymbal Bank application to the cymbal-gke-cymbal-01-ap GKE cluster in the cymbal-bank-ns namespace.

gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME
kubectl apply -f ./extras/jwt/jwt-secret.yaml -n $NAMESPACE_NAME_1 
kubectl apply -f ./kubernetes-manifests -n $NAMESPACE_NAME_1 


# Clone the Online Boutique repository
echo "Cloning Online Boutique repository..."
if [ -d "microservices-demo" ]; then
    echo "Online Boutique directory already exists. Skipping clone."
else
    git clone https://github.com/GoogleCloudPlatform/microservices-demo.git || { echo "ERROR: Failed to clone repository. Exiting."; exit 1; }
fi

ONLINE_DIR="microservices-demo"
if [ ! -d "$ONLINE_DIR" ]; then
    echo "ERROR: Expected directory '$ONLINE_DIR' not found after cloning. Exiting."
    exit 1
fi

cd "$ONLINE_DIR" || { echo "ERROR: Failed to change directory to $ONLINE_DIR. Exiting."; exit 1; }

#Deploy the Online Boutique application to the cymbal-gke-cymbal-01-ap GKE cluster in online-boutique-ns namespace.


export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"
export NAMESPACE_NAME_1="cymbal-bank-ns"
export NAMESPACE_NAME_2="online-boutique-ns"

gcloud container fleet memberships get-credentials $MEMBERSHIP_NAME
kubectl apply -f ./release/kubernetes-manifests.yaml -n $NAMESPACE_NAME_2 
