# !/bin/bash
PROJECT_ID=$(gcloud config get-value project)
export INSTANCE_NAME='menu-catalog'
export DB_REGION="us-central1"
# Everytime new environment deployed this SA needs to be updated:
export COMPUTE_SA="838199965701-compute@developer.gserviceaccount.com"

echo "☁️ Enabling the Cloud SQL API..."
gcloud config set project ${PROJECT_ID}
gcloud services enable sqladmin.googleapis.com

CSQL_EXISTS=$(gcloud sql instances list --filter="${INSTANCE_NAME}" | wc -l)
if [ $CSQL_EXISTS = "0" ]; then
  echo "☁️ Creating Cloud SQL instance: ${INSTANCE_NAME} ..."
  gcloud sql instances create $INSTANCE_NAME \
    --database-version=POSTGRES_15 --tier=db-custom-1-3840 \
    --root-password=password123 \
    --network=default \
    --no-assign-ip \
    --region=${DB_REGION} --project ${PROJECT_ID}
fi

echo "☁️ All done creating ${INSTANCE_NAME} ..."
INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)')

echo "☁️ Create an SQL user menu-user with the password menupassword123..."
gcloud sql users create menu-user \
   --instance=$INSTANCE_NAME --password=menupassword123 --project ${PROJECT_ID}

echo "☁️ SQL user menu-user has been created"

# Add the database menu-db to the menu-catalog instance
MENU_DB_EXISTS=$(gcloud sql databases list --instance=${INSTANCE_NAME} --filter="menu-db" | wc -l)
if [ $MENU_DB_EXISTS = "0" ]; then
  echo "☁️ Creating menu-db in ${INSTANCE_NAME}..."
  gcloud sql databases create menu-db --instance=$INSTANCE_NAME --project ${PROJECT_ID}
fi

# Add the Cloud SQL Client role to the default Compute Engine service account:
echo " Add the Cloud SQL Client role to the default Compute Engine service account ..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:$COMPUTE_SA" \
  --role="roles/cloudsql.client"

echo "⭐️ Done."