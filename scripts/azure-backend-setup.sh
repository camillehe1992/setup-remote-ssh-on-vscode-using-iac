#!/bin/bash

# Setup script to create Azure Storage Account for Terraform state
# Usage: ./setup-backend.sh <suffix>

set -e

# Configuration
SUFFIX=${1:-$(openssl rand -hex 4)}
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="tfstate${SUFFIX}"  # Must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="chinanorth3"

echo "Creating Terraform state backend in Azure..."
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Location: $LOCATION"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --subscription $ARM_SUBSCRIPTION_ID

# Create storage account
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --encryption-services blob \
    --subscription $ARM_SUBSCRIPTION_ID \
    --tags "Environment=terraform" "Project=terraform-state"

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --subscription $ARM_SUBSCRIPTION_ID \
    --query '[0].value' -o tsv)

# Create blob container
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY \
    --subscription $ARM_SUBSCRIPTION_ID

# Enable soft delete for blob container (optional but recommended)
az storage blob service-properties delete-policy update \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY \
    --enable true \
    --subscription $ARM_SUBSCRIPTION_ID \
    --days-retained 7

# Output information
echo "=========================================="
echo "✅ Backend setup complete!"
echo "=========================================="
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Container: $CONTAINER_NAME"
echo ""
echo "To initialize Terraform with this backend:"
echo "export ARM_ACCESS_KEY=\"$ACCOUNT_KEY\""
echo "terraform init -backend-config=backend-config.hcl"
echo ""
echo "Or save the access key to a secure location:"
echo "echo \"$ACCOUNT_KEY\" > terraform.access.key"
echo "=========================================="
