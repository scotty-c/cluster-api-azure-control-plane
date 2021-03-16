# Cluster API Azure control plane.

## Introduction
The idea behind this repo was to make it super easy to spin up a Kubernetes control plane to use as a [cluster api](https://cluster-api.sigs.k8s.io/) server.  
This will work both locally or on Azure as it based on [cloud-init](https://cloudinit.readthedocs.io/en/latest/)  

## Running locally 
When runnning the server locally you will need to install [multipass](https://multipass.run/).  
This is an open source project from canonical which will work on Windows, MacOS and Linux. So what ever you OS you choose to develop on multipass will have you covered. This is the only dependancy of the project. 

Once multipass is installed just run the following 
```
curl -L -o cloud-init.yaml 'https://raw.githubusercontent.com/scotty-c/cluster-api-azure-control-plane/main/cloud-init.yaml'
multipass launch --name cluster-api --cpus 2 --mem 4G --cloud-init cloud-init.yaml
```
Under the hood we are spining up a new [Ubuntu server](https://ubuntu.com/download/server) for the control plane we are going to use [microk8s](https://microk8s.io/). This will give us a super light control plane to use to deploy our Kubernetes clusters on Azure. 

There is a known issue that you might get the following error when deploying this locally  
```
launch failed: The following errors occurred:                                   
timed out waiting for initialization to complete
```
This is ok, the installation will continue inside the server. We can check this by tailing the logs but first we need to acess the servers shell.  
To do this we just issue the command `multipass shell cluster-api`  
You will be greeted with the following MOTD  
To follow the logs `tail -f output.txt`  

To configure you azure credentials and get the cluster ready follow the instructions on the MOTD


```
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-66-generic x86_64)

Welcome to your Azure Cluster API machine

If the below commands are not available follow the install log
tail -f output.txt

# Sign into your Azure account
az login
export AZURE_SUBSCRIPTION_ID="<SubscriptionId>"

# Create an Azure Service Principal and paste the output here
export AZURE_TENANT_ID="<Tenant>"
export AZURE_CLIENT_ID="<AppId>"
export AZURE_CLIENT_SECRET="<Password>"

# Azure cloud settings
# To use the default public cloud, otherwise set to AzureChinaCloud|AzureGermanCloud|AzureUSGovernmentCloud
export AZURE_ENVIRONMENT="AzurePublicCloud"

export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "$AZURE_SUBSCRIPTION_ID" | base64 | tr -d n)"
export AZURE_TENANT_ID_B64="$(echo -n "$AZURE_TENANT_ID" | base64 | tr -d n)"
export AZURE_CLIENT_ID_B64="$(echo -n "$AZURE_CLIENT_ID" | base64 | tr -d n)"
export AZURE_CLIENT_SECRET_B64="$(echo -n "$AZURE_CLIENT_SECRET" | base64 | tr -d n)"

# Finally, initialize the management cluster
clusterctl init --infrastructure azure
```
## Running on Azure
To run this on Azure we will use exactly the same code. We will make the assumption that you have the [Azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) that is signed into to your subscription. 

Then just run the script `./deploy-azure.sh`  
The script will ask you a couple of questions 
```
Enter the subscription to use: 
Enter the resource group for the vm: 
Enter the name for the vm:
```
Then print out the instructions to access the server.  
Once you have access to the servers shell just `tail -f output.txt`  
The MOTD will give you the rest of the instructions. 