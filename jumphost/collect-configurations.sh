#!/bin/bash -ex
#
#    Secured AKS deployment
#    Copyright (C) 2016 Fortinet  Ltd.
#
#    Authors: Nicolas Thomss  <nthomas@fortinet.com>
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

# Be sure to have login (az login) first

GROUP_NAME="ftnt-demo-aks"
#REGION="francecentral"
REGION="westeurope"
  # see https://docs.microsoft.com/en-gb/azure/aks/private-clusters

# Node count if quota restrictions
az aks get-credentials --resource-group "$GROUP_NAME"  --name "private-AKS"

FGTAZIP=`az network public-ip show --name FGTPublicIP --resource-group $GROUP_NAME  --query ipAddress -o tsv`
echo " You can login on fortigate at https://$FGTAZIP"
echo "Kubernetes credentials are in ~/.kube/config"
## KAPI_ID=`az network private-endpoint show --name kube-apiserver --resource-group $AKS_RESOURCE_GROUP --query "networkInterfaces[0].id" -o tsv`
## KAPI_IP=`az network  nic show --ids $KAPI_ID --query "ipConfigurations[0].privateIpAddress" -o tsv`

