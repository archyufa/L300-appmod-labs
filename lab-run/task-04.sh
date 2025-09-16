# !/bin/bash
PROJECT_ID=$(gcloud config get-value project)
# Everytime new environment deployed this SA needs to be updated:
export COMPUTE_SA="838199965701-compute@developer.gserviceaccount.com"


# Create a secret named db-password-secret with automatic replication
gcloud secrets create db-password-secret --replication-policy="automatic" --project=$PROJECT_ID


# Add the database password to the secret
echo -n "menupassword123" | gcloud secrets versions add db-password-secret --data-file=- --project=$PROJECT_ID 

# Grant the Secret Manager Secret Accessor role to the Compute Engine service account
gcloud secrets add-iam-policy-binding db-password-secret \
    --member="serviceAccount:$COMPUTE_SA" \
    --role="roles/secretmanager.secretAccessor"