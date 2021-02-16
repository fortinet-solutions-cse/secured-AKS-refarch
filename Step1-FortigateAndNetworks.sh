#!/bin/bash -e
#
#    Secured AKS deployment
#    Copyright (C) 2021 Fortinet  Ltd.
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

# Be sure to have login (az login) first

az group create --name "$GROUP_NAME"  --location "$REGION"

DEPLOY_NAME=$GROUP_NAME"-TRANSIT"
echo "validating deployment"
az  deployment group validate --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-uri https://raw.githubusercontent.com/40net-cloud/fortinet-azure-solutions/main/FortiGate/A-Single-VM/azuredeploy.json  \
 --parameters myparameters.json > $GROUP_NAME.validate.json
echo "Deploying single VM and subnets"
az  deployment group create --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-uri https://raw.githubusercontent.com/40net-cloud/fortinet-azure-solutions/main/FortiGate/A-Single-VM/azuredeploy.json  \
 --parameters myparameters.json

query="[?virtualMachine.name.starts_with(@, 'ftnt-ws')].{virtualMachine:virtualMachine.name, publicIP:virtualMachine.network.publicIpAddresses[0].ipAddress,privateIP:virtualMachine.network.privateIpAddresses[0]}"
az vm list-ip-addresses --query "$query" --output tsv

SNET2=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name ftnt-demo-Vnet     --query "[1].id" --output tsv`
