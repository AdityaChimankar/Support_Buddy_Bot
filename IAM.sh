#!/bin/bash

# Authenticate with Google Cloud

gcloud config set project new-joiner-chatbot

# Create a service account
gcloud iam service-accounts create chatbot-service-account \
  --description="Service account for chatbot" \
  --display-name="Chatbot Service Account"

# Assign IAM roles
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/dialogflow.admin"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/dialogflow.client"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="serviceAccount:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"
