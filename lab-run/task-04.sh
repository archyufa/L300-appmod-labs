#!/bin/bash

# Create a secret named db-password-secret with automatic replication
gcloud secrets create db-password-secret --replication-policy="automatic"

# Add the database password to the secret
echo -n "menupassword123" | gcloud secrets versions add db-password-secret --data-file=-

# Grant the Secret Manager Secret Accessor role to the Compute Engine service account
PROJECT_ID=$(gcloud config get-value project)
gcloud secrets add-iam-policy-binding db-password-secret \
    --member="serviceAccount:${PROJECT_ID}@cloudbuild.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"