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

# see https://docs.microsoft.com/en-gb/azure/aks/private-cluster



## get the ID of the '4th subnet (protected)' in the FGT deployment
WPOOLSUBNET=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name ftnt-demo-Vnet   --query "[3].id" --output tsv`

echo "create an AKS Windows node pool on second subnet"

az aks nodepool add \
    --resource-group "$GROUP_NAME" \
    --cluster-name "private-AKS" \
    --vnet-subnet-id $WPOOLSUBNET\
    --node-count 2 \
    --os-type Windows \
    --name npwin

# https://docs.microsoft.com/en-us/azure/aks/windows-container-cli

echo " *** DONE *** "
