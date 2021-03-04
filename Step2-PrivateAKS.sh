#!/bin/bash -e
#
#    Secured AKS deployment
#    Copyright (C) 2016 Fortinet  Ltd.
#
#    Authors: Nicolas Thomas  <nthomas AT fortinet.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# see https://docs.microsoft.com/en-gb/azure/aks/private-clusters
SNET2=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name ftnt-demo-Vnet     --query "[1].id" --output tsv`

echo "deploy jumphost"
## service VM on the transit network for accessing AKS
az vm create \
  --resource-group "$GROUP_NAME" --location "$REGION"\
  --name ftnt-demo-jumphost \
  --image UbuntuLTS \
  --admin-username azureuser \
  --admin-password Fortin3t-aks \
  --private-ip-address 172.27.40.73 \
  --subnet $SNET2  --authentication-type password  --no-wait



# Ref https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/use-network-policies.md
# Create a service principal and read in the application ID
# to find a previously created one :
# az ad sp list --show-mine --query "[?displayName=='ForSecureAKS'].{id:appId}" -o tsv
# is the id with the same name
CHECKSP=`az ad sp list --show-mine -o tsv --query "[?displayName == 'ForSecureAKS.io'].appId"`
[ -z $CHECKSP ] ||  az ad sp delete  --id $CHECKSP

SP=$(az ad sp create-for-rbac --output json  --name ForSecureAKS.io)
SP_ID=$(echo $SP | jq -r .appId)
SP_PASSWORD=$(echo $SP | jq -r .password)

# Wait 25 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate..."
sleep 25

# Get the virtual network resource ID
VNET_ID=$(az network vnet show --resource-group $GROUP_NAME --name  ftnt-demo-Vnet --query id -o tsv)

# Assign the service principal Contributor permissions to the virtual network resource
az role assignment create --assignee $SP_ID --scope $VNET_ID --role Contributor

AKSSUBNET=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name ftnt-demo-Vnet   --query "[2].id" --output tsv`

# Install the aks-preview extension
az extension add --name aks-preview
echo "Force all subnet traffic through the Fortigate"
az network route-table route delete --route-table-name ftnt-demo-RT-PROTECTED-A -g $GROUP_NAME --name Subnet 
az network route-table route delete --route-table-name ftnt-demo-RT-PROTECTED-B -g $GROUP_NAME --name Subnet 

# set this to the name of your Azure Container Registry.  It must be globally unique
MYACR=`echo $GROUP_NAME |sed 's/-//g'`ContainerReg
# Run the following line to create an Azure Container Registry if you do not already have one
echo "create an azure registry"
az acr create -n $MYACR -g $GROUP_NAME --sku basic

echo "create an AKS cluster"

az aks create \
    --resource-group "$GROUP_NAME" \
    --name "private-AKS" \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $AKSSUBNET\
    --service-cidr 10.8.0.0/16 \
    --dns-service-ip 10.8.0.53 \
    --docker-bridge-address 172.17.0.1/16 \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --node-count 3 \
    --node-vm-size Standard_A2_v2\
    --enable-cluster-autoscaler \
    --min-count 2 --max-count 5 \
    --windows-admin-password Fortin3t-aks-win --windows-admin-username azureuser  \
    --attach-acr $MYACR \
    --generate-ssh-keys  --outbound-type userDefinedRouting
#   --enable-pod-security-policy
#    --dns-name-prefix ftnt-demo

# https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype
# check addons: https://github.com/Azure/aks-engine/blob/master/docs/topics/clusterdefinitions.md#addons (like tiller/helm)
# next private registry https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration

# add the private dns to the transit network for kubectl to work on jumphost
AKS_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name private-AKS --query nodeResourceGroup -o tsv)
AKS_PRIV_DNS=$(az network private-dns  zone list -g $AKS_RESOURCE_GROUP -o tsv --query [0].name)
FTNT_VNET_ID=$(az network vnet show --resource-group $GROUP_NAME --name ftnt-demo-vnet --query "id" -o tsv )
echo "add AKS dns zone to transit networks"
az network private-dns  link vnet create --name aks-dns --virtual-network "$FTNT_VNET_ID" --zone-name "$AKS_PRIV_DNS" \
   --registration-enabled false -g "$AKS_RESOURCE_GROUP"
echo "get Kubernetes admin credentials"
# Node count if quota restrictions
az aks get-credentials --resource-group "$GROUP_NAME"  --name "private-AKS" --overwrite-existing

FGTAZIP=`az network public-ip show --name FGTPublicIP   --resource-group $GROUP_NAME  --query ipAddress -o tsv`
echo " *** DONE *** "
echo ""
echo " You can login on fortigate at https://$FGTAZIP"
echo "Kubernetes credentials are in ~/.kube/config"

echo "To configure the Fortigate do: "
echo "ansible-playbook fgt-playbook.yaml -i hosts -e ansible_host=$FGTAZIP"
echo "Access to jumphost : ssh azureuser@$FGTAZIP -p 2222"
echo "Or setup forticlient VPN with IP: $FGTAZIP aks/Fortin3t-aks"