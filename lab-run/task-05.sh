# !/bin/bash
#1. Clone the Cymbal Eats Repository & Navigate:

git clone  https://github.com/GoogleCloudPlatform/cymbal-eats.git
cd cymbal-eats/menu-service

#2. Compile the Application with Maven:

mvn clean package -DskipTests


#3. Configure Docker Authentication for Artifact Registry

gcloud auth configure-docker us-central1-docker.pkg.dev


#4 Set environment variables for clarity
export PROJECT_ID=$(gcloud config get-value project)
#Update every time restart Lab
export REPO_LOCATION="us-central1"
export REPOSITORY="container-repo"
export IMAGE_NAME="cymbal-eats"
export IMAGE_TAG="latest"

# Construct the full image URI for Artifact Registry
export IMAGE_URI="${REPO_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"

# Build the Docker image
# The "." indicates the build context is the current directory
docker build -t ${IMAGE_URI} .

# Push the Docker image to Artifact Registry
docker push ${IMAGE_URI}

echo "Image build and push complete: ${IMAGE_URI}"


# 4. Deploy the Cloud Run service named menu-service using the cymbal-eats Docker image and with direct egress traffic enabled, by applying the following configurations:

export CLOUD_SQL_INSTANCE_IP="10.37.112.3"

gcloud run deploy menu-service \
  --image=us-central1-docker.pkg.dev/qwiklabs-gcp-04-b4a2bfb8d4d3/container-repo/cymbal-eats:latest \
  --region=us-central1 \
  --allow-unauthenticated \
  --network=default \
  --subnet=default \
  --vpc-egress=all-traffic \
  --set-secrets="DB_PASS=db-password-secret:latest" \
  --set-env-vars="DB_USER=menu-user,DB_DATABASE=menu-db,DB_HOST=$CLOUD_SQL_INSTANCE_IP" \
  --project=$PROJECT_ID


# 5. Test the successful deployment of the menu-service on Cloud Run and verify the connection by sending a POST request to MENU_SERVICE_URL/menu using below json:

export MENU_SERVICE_URL=https://menu-service-pwliv465jq-uc.a.run.app

  curl -X POST \
    -H "Content-Type: application/json" \
    -d '{
         "itemImageURL": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7",
         "itemName": "Curry Plate",
         "itemPrice": 12.5,
         "itemThumbnailURL": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7",
         "spiceLevel": 3,
         "status": "Ready",
         "tagLine": "Spicy touch for your taste buds!!"
     }' \
    "${MENU_SERVICE_URL}/menu"