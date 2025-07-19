# Technical Documentation: Building a New Joiner Chatbot

**Date**: July 19, 2025

## 1 Overview
This document provides a comprehensive guide for building a chatbot to assist new joiners, leveraging Google Cloud services, including Vertex AI, Google Cloud Storage (GCS), BigQuery, and Dialogflow CX, with integration to Microsoft Teams and Google Calendar/Outlook. The chatbot delivers personalized responses based on employee data, supports onboarding, and handles queries about insurance policies, team tech stacks, IT support, and emergency contacts. It is designed for scalability, security, and multilingual support, ensuring compliance with data privacy regulations such as GDPR and HIPAA. Microsoft Teams serves as the primary and sole interface for user interactions.

### Key Features
- **Personalized Responses**: Tailored to employee data (e.g., role, team, business unit).
- **Document Retrieval**: Uses Vertex AI with Retrieval-Augmented Generation (RAG) to fetch insurance policy details from GCS.
- **Microsoft Teams Access**: Available exclusively via Microsoft Teams for seamless in-workflow interactions.
- **Multilingual Support**: Enabled through Google Cloud Translation API.
- **Integrations**: Connects with Microsoft Teams and Google Calendar/Outlook for event and meeting reminders.
- **Security**: Implements Google Cloud Identity-Aware Proxy (IAP) and encryption for compliance.

## 2 Tech Stack
### 2.1 Backend and AI
- **Google Cloud Vertex AI**: Utilizes the Gemini Pro model with RAG for natural language processing and document-based query handling.
- **Dialogflow CX**: Manages conversation logic, intent detection, and entity extraction for structured queries.
- **Google Cloud Storage (GCS)**: Stores unstructured data, such as insurance policy PDFs.
- **BigQuery**: Stores structured employee data, including team and tech stack details.
- **Google Cloud Functions**: Handles backend logic and API integrations.
- **Google Cloud Translation API**: Provides multilingual support.
- **Google Cloud Natural Language API**: Performs sentiment analysis for user interactions.

### 2.2 Integrations
- **Microsoft Teams**: Enabled via Teams AI Library or Zapier for in-workflow access.
- **Google Calendar/Outlook**: Supports event and meeting reminders.

### 2.3 Security
- **Google Cloud Identity-Aware Proxy (IAP)**: Secures access to the chatbot.
- **Encryption**: Ensures compliance with GDPR and HIPAA for data in transit and at rest.
- **IAM Roles**: Restricts access to sensitive data in GCS and BigQuery.

## 3 Implementation Steps
### 3.1 Set Up Google Cloud Project
1. **Create a Google Cloud Project**:
   - Navigate to the [Google Cloud Console](https://console.cloud.google.com).
   - Create a new project (e.g., `new-joiner-chatbot`).
   - Enable billing for the project.
2. **Enable Required APIs**:
   - Enable: Vertex AI API, Dialogflow API, Cloud Storage API, BigQuery API, Cloud Functions API, Translation API, Natural Language API.
3. **Set Up Authentication**:
   - Create a service account in the Google Cloud Console.
   - Assign roles: `Vertex AI User`, `Dialogflow API Admin`, `Dialogflow API Client`, `Service Usage Consumer`, `Storage Admin`, `BigQuery Admin`.
   - Download the JSON key file.

```bash
#!/bin/bash
# Creating a service account and assigning roles
gcloud iam service-accounts create chatbot-service-account \
  --description="Service account for chatbot" \
  --display-name="Chatbot Service Account"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/dialogflow.admin"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/dialogflow.client"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
gcloud projects add-iam-policy-binding new-joiner-chatbot \
  --member="service-account:chatbot-service-account@new-joiner-chatbot.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"
```

### 3.2 Store Data in Google Cloud Storage and BigQuery
1. **Google Cloud Storage**:
   - Create a GCS bucket (e.g., `new-joiner-docs`) to store unstructured data, such as `insurance_policy.pdf`.
   - Upload documents using the Google Cloud Storage API.

```python
from google.cloud import storage

def upload_to_gcs(bucket_name, source_file_name, destination_blob_name):
    """Upload a file to Google Cloud Storage."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_name)
    print(f"File {source_file_name} uploaded to {destination_blob_name}.")

# Example usage
upload_to_gcs("new-joiner-docs", "insurance_policy.pdf", "policies/insurance_policy.pdf")
```

2. **BigQuery**:
   - Create a dataset (e.g., `new_joiner_data`).
   - Create tables for employee data, team tech stacks, and emergency contacts.

```sql
----create BQ table--------
CREATE TABLE `project_id.dataset_id.employee_data` (
  emp_id STRING,
  employee_name STRING,
  employee_mail_id STRING,
  employee_skill_set STRING,
  employee_manager_name STRING,
  employee_BU STRING,
  employee_platform_in_BU STRING
);

----------loading to BQ from GCS------
LOAD DATA OVERWRITE `new-joiner-chatbot.employee_tech_stack.employee_data`
FROM FILES (
  format = 'CSV',
  uris = ['gs://new-joiner-docs/employee_data_tech_stack_information.csv'],
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE
);
```

### 3.3 Configure Dialogflow CX
1. **Create a Dialogflow CX Agent**:
   - In the [Dialogflow CX Console](https://dialogflow.cloud.google.com/cx), create a new agent (e.g., `NewJoinerBot`).
   - Set the default language (e.g., English) and enable additional languages as needed.
2. **Define Intents and Entities**:
   - **Intents**: `tech_stack`, `it_support`, `emergency_contacts`, `document_query` (for insurance-related queries handled by Vertex AI).
   - **Entities**: `team` (e.g., Data Engineering, Marketing), `policy_type` (e.g., Health, Dental).
3. **Configure Webhook for Insurance Queries**:
   - Create a general intent (`document_query`) or use the fallback intent to route insurance-related queries to a webhook that calls Vertex AI with RAG.

### 3.4 Set Up Vertex AI with RAG
1. **Configure Vertex AI**:
   - Initialize Vertex AI with the Gemini Pro model in the `new-joiner-chatbot` project.
   - Set up RAG to connect to GCS for document retrieval.

```python
from google.cloud import aiplatform

def configure_rag():
    """Configure RAG for Vertex AI with Google Cloud Storage."""
    aiplatform.init(project="new-joiner-chatbot", location="us-central1")
    # Configure data store for Google Cloud Storage
    data_store = {
        "data_briefing": "data_store",
        "display_name": "new-joiner-docs",
        "context_config": {"cloud_storage": {"bucket_name": "new-joiner-docs"}}
    }
    # Additional configuration done in Vertex AI Console
    print("RAG configured with Google Cloud Storage.")
```

2. **Handle Insurance Queries**:
   - Use Vertex AI's generative AI model with RAG to retrieve and process insurance policy documents from GCS.
   - Integrate with BigQuery to personalize responses based on employee data (e.g., role, insurance_plan).

### 3.5 Develop the Chatbot Backend
1. **Vertex AI with Gemini Pro**:
   - Initialize Vertex AI for natural language processing tasks.

```python
from google.cloud import aiplatform
from vertexai.language_models import ChatModel

def initialize_vertex_ai():
    """Initialize Vertex AI with Gemini Pro."""
    aiplatform.init(project="new-joiner-chatbot", location="us-central1")
    chat_model = ChatModel.from_pretrained("gemini-pro")
    return chat_model

def generate_response(query, context):
    """Generate response using Gemini Pro."""
    chat_model = initialize_vertex_ai()
    response = chat_model.start_chat(context=context).send_message(query)
    return response.text
```

2. **Google Cloud Functions**:
   - Create a Cloud Function to query BigQuery for structured data.

```python
from google.cloud import bigquery
from flask import jsonify

def query_bigquery(request):
    """Cloud Function to query BigQuery for chatbot responses."""
    request_json = request.get_json()
    query = request_json.get("query")
    client = bigquery.Client()
    query_job = client.query(f"SELECT * FROM new_joiner_data.employee_details WHERE employee_id = '{query['employee_id']}'")
    results = query_job.result()
    return jsonify([dict(row) for row in results])
```

### 3.6 Integrate with Microsoft Teams
1. **Use Teams AI Library**:
   - Set up a Teams bot using the Teams AI Library.
   - Configure actions in `actions.json` to handle queries within Teams.

```json
{
  "actions": [
    {
      "id": "fetch_details",
      "description": "Fetch employee or team details",
      "endpoint": "https://us-central1-new-joiner-chatbot.cloudfunctions.net/query_bigquery"
    },
    {
      "id": "fetch_insurance",
      "description": "Fetch insurance policy details",
      "endpoint": "https://us-central1-new-joiner-chatbot.cloudfunctions.net/query_bigquery"
    }
  ]
}
```

2. **Deploy to Teams**:
   - Use the Microsoft 365 Agents Toolkit in Visual Studio Code to deploy the bot to Microsoft Teams.
   - Ensure the bot is registered in the Microsoft Azure Bot Service and configured with the appropriate messaging endpoint linked to the Google Cloud Function.

3. **Test the Integration**:
   - In Microsoft Teams, add the bot to a channel or test it via direct messages.
   - Verify that queries (e.g., “What’s my insurance policy?” or “Who’s my IT support contact?”) are correctly routed to Dialogflow CX and Vertex AI.

### 3.7 Deploy the Chatbot
1. Deploy the backend to Vertex AI Agent Engine.
2. Monitor with Google Cloud Logging to ensure the bot operates correctly within Teams.

### 3.8 Security and Compliance
1. Enable Identity-Aware Proxy (IAP) for secure access to backend services.
2. Encrypt sensitive data in BigQuery and GCS.
3. Restrict access using IAM roles (e.g., limit GCS bucket access to Vertex AI and the service account).

### 3.9 Monitor and Iterate
1. Use Google Cloud Monitoring to track performance metrics, such as response times and query success rates in Teams.
2. Analyze common queries to identify onboarding gaps.
3. Update intents and data sources based on user feedback from Teams interactions.

## 4 Sample Query Flow
### Query: "What’s the health insurance coverage for my role?"
1. In Microsoft Teams, the user sends the query to the chatbot.
2. Dialogflow CX detects the `document_query` intent or routes to the fallback intent.
3. The webhook calls Vertex AI, which uses RAG to retrieve relevant insurance policy details from GCS.
4. Vertex AI queries BigQuery to fetch the user’s role and insurance plan.
5. Response in Teams: "As a software engineer, you’re enrolled in Plan A, which covers medical, dental, and vision. [Link to policy]. Need help filing a claim?"

### Query: "Who’s my IT support contact?"
1. In Microsoft Teams, the user sends the query.
2. Dialogflow CX detects the `it_support` intent.
3. Queries BigQuery for team-specific IT contacts.
4. Response in Teams: "Your IT support contact is Jane Doe (jane.doe@company.com, +1-123-456-7890). Want to log a ticket?"

## 5 Additional Considerations
- **Scalability**: Use Cloud Load Balancing to ensure high availability for backend services supporting Teams.
- **Cost Management**: Monitor usage of Vertex AI, Dialogflow CX, and GCS to optimize costs.
- **User Training**: Provide a help command within Teams (e.g., “/help”) and a user guide for new joiners.
- **Multilingual Support**: Enable Google Cloud Translation API for non-English queries in Teams.
- **Security**: Ensure GCS buckets (`new-joiner-docs`) and BigQuery datasets (`new_joiner_data`) have strict IAM permissions limited to the service account and Vertex AI.

## 6 Conclusion
This document outlines the process for building a scalable, secure, and efficient chatbot for new joiners, accessible exclusively through Microsoft Teams. By leveraging Vertex AI with RAG for insurance queries, BigQuery for structured employee data, and Dialogflow CX for conversational flows, the chatbot provides personalized and dynamic support. Integration with Microsoft Teams and Google Calendar/Outlook ensures seamless access within the organization’s primary communication platform. For further assistance, refer to the [Vertex AI documentation](https://cloud.google.com/vertex-ai/docs) or [Dialogflow CX documentation](https://cloud.google.com/dialogflow/cx/docs).
