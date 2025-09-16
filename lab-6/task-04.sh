#!/bin/bash

# This script enable fleet logs in Cloud Shell and view team-based logs.

# --- Configuration ---
# Ensure these variables are set correctly for your environment.
export PROJECT_ID=$(gcloud config get-value project)

# Variables 
export CLUSTER_NAME="cymbal-gke-cymbal-01-ap"
export MEMBERSHIP_NAME="${CLUSTER_NAME}"
export NAMESPACE_NAME_1="cymbal-bank-ns"
export NAMESPACE_NAME_2="online-boutique-ns"

# Create a JSON configuration file for fleet logging using the following code:

echo "Creating JSON config file for fleet logging..."
cat <<EOF > fleet_logging_config.json
{
  "loggingConfig": {
      "defaultConfig": {
          "mode": "COPY"
      },
      "fleetScopeLogsConfig": {
          "mode": "MOVE"
      }
  }
}
EOF

# Apply the Configuration:

gcloud container fleet fleetobservability update \
  --logging-config="fleet_logging_config.json"
