#!/bin/bash
# az extension add --name containerapp --upgrade
# az provider register --namespace Microsoft.App

RESOURCE_GROUP='prime_resources'
LOCATION='eastus'
CONTAINERAPPS_ENVIRONMENT="Test"
REGISTRY_CONTAINER_NAME="ghcr.io/snippets-n-memes/loco-logo"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION 

az containerapp create \
  --image $REGISTRY_CONTAINER_NAME \
  --name my-container-app \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --ingress external \
  --target-port 80 \
  --transport http \
  --max-replicas 1 \
  --min-replicas 1

exit 0
