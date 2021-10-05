#!/bin/bash

set -e
set -o pipefail


read -p "Enter the subscription to use: "  SUB
read -p "Enter the resource group for the vm: " RS
read -p "Enter the name for the vm: " NAME


az account set --subscription "$SUB"

curl -L -o cloud-init.txt 'https://raw.githubusercontent.com/scotty-c/cluster-api-azure-control-plane/main/cloud-init.yaml'

az vm create \
  --resource-group "$RS" \
  --name $NAME \
  --image UbuntuLTS \
  --size  Standard_B2S \
  --custom-data cloud-init.txt \
  --admin-username ubuntu \
  --ssh-key-values ~/.ssh/id_rsa.pub
   

IP=$(az vm show -d  --resource-group $RS --name $NAME --query publicIps -o tsv
)

echo "Access your vm with  ssh ubuntu@$IP"

rm cloud-init.txt

  
