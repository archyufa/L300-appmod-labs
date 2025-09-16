#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)

gcloud services enable run.googleapis.com

# 1. Allocate an IP Address Range
 
echo "Allocating an IP Address Range ..."
gcloud compute addresses create google-managed-services-default \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=20 \
    --network=default \
    --project="$PROJECT_ID"

echo "Allocated an IP Address Range 20 ..."

#2. This command creates the private connection, linking your default VPC network with the service producer network
# (servicenetworking.googleapis.com) using the IP range you just allocated.

echo "Creating a Private Connection..."

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default \
    --project="$PROJECT_ID"

echo "Private Connection has been created."