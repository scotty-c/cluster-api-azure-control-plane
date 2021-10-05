#!/bin/bash

set -e
set -o pipefail

read -p "Enter the subscription to use: "  SUB
read -p "Enter region to deploy the cluster: "  LOCATION

az account set --subscription "$SUB"

CLUSTER_RG=cluster-api
SP_NAME=cluster-api

pre_checks () {
RG_THERE=$(az group exists --name $CLUSTER_RG)
echo "Checking if the resource group exisits"
if [ $RG_THERE == true ]
then 
    echo "The resource group has already been created"
else
    echo "Creating the resource group"
    az group create -l $LOCATION -n $CLUSTER_RG
fi

# TODO look for better way to test for sp
SP_THERE=$(az ad sp list --display-name $SP_NAME -o table )
echo "Checking for pre created service principal"
if [ -z "$SP_THERE" ]
then
      echo "The service principal does not exsist"
else
      echo "Deleting service principal, we will recreate it later in the script"
      az ad sp delete --id http://$SP_NAME

fi
}

create_cluster () {
AZURE_CLIENT_SECRET=$(az ad sp create-for-rbac --name $SP_NAME --role Contributor | jq -r .password)
AZURE_CLIENT_ID=$(az ad sp show --id http://$SP_NAME --query appId --output tsv)
AZURE_TENANT_ID=$(az ad sp show --id http://$SP_NAME --query appOwnerTenantId --output tsv )
echo ""
echo "The client secret is $AZURE_CLIENT_SECRET"
sleep 30
clusterctl init --infrastructure azure
}

pre_checks
create_cluster
