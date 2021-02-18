#!/bin/bash -e
#
#    Configure Fortigate Kubernetes connector
#
#    Authors: Nicolas Thomss  <nthomas AT fortinet.com>
#
# Be sure to have login (az login) first


echo "collecting information on Azure"

AKS_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name private-AKS --query nodeResourceGroup -o tsv)
KAPI_ID=`az network private-endpoint show --name kube-apiserver --resource-group $AKS_RESOURCE_GROUP --query "networkInterfaces[0].id" -o tsv`
KAPI_IP=`az network  nic show --ids $KAPI_ID --query "ipConfigurations[0].privateIpAddress" -o tsv`

echo "create service account for the connector"
kubectl -n kube-system create serviceaccount fortigate || true
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:fortigate || true
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='fortigate')].data.token}" -n kube-system | base64 -d)

FGTAZIP=`az network public-ip show --name FGTPublicIP  --resource-group $GROUP_NAME  --query ipAddress -o tsv`

echo "configure your Kubernetes SDN connector with the following cli on https://$FGTAZIP"
cat <<EOF
config system sdn-connector
    edit "AKS"
        set type kubernetes
        set server $KAPI_IP
        set server-port 443
        set secret-token $TOKEN
        set update-interval 30
    next
end

EOF