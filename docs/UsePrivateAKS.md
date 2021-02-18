
https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough


# SSH access to nodes (VMs) for debug

Using the script you should have a direct ssh accesss to the nodes (VMs) with the user which create the cluster.

If not ref: https://docs.microsoft.com/en-us/azure/aks/ssh (for debug)


```
az@az-aks-cli:/Azure $kubectl get nodes -o wide
NAME                                STATUS   ROLES   AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-13072840-vmss000000   Ready    agent   61m   v1.15.10   10.40.0.4     <none>        Ubuntu 16.04.6 LTS   4.15.0-1071-azure   docker://3.0.10+azure
aks-nodepool1-13072840-vmss000001   Ready    agent   61m   v1.15.10   10.40.0.35    <none>        Ubuntu 16.04.6 LTS   4.15.0-1071-azure   docker://3.0.10+azure
az@az-aks-cli:/Azure $ssh azureuser@10.40.0.4 
```
The above example should be successfull. This allow you to see the work done on Kubernetes nodes (docker cli).
You should NOT allow this in production.

# SSL inspection
## K8S Nodes (i.e. VMs)
Ref https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
You get the Fortinet_AKS_CA.crt from your running Fortigate in the custom deep inspection security profile download.

```
export FGTCA=$(base64 Fortinet_AKS_CA.cer -w0) # or -b0 on MacOS
GROUP_NAME="ftnt-demo-aks"
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name private-AKS --query nodeResourceGroup -o tsv) 
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)

az vmss extension set      --resource-group $CLUSTER_RESOURCE_GROUP     --vmss-name $SCALE_SET_NAME   \
    --version 2.0 --publisher Microsoft.Azure.Extensions     --name CustomScript    \
    --protected-settings "{\"commandToExecute\": \"echo $FGTCA| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates --fresh; service docker restart \"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
```

This install and trust the Fortigate CA for SSL inspection, allowing antivirus and DLP on your infra and application code.
You must at least restart the docker deamon on nodes.

## quick test

```
kubectl run eicar --image=fortinetsolutioncse/ubuntu-eicar bash -it
```

Should trigger the antivirus
## K8S containers

# Helm development
https://docs.microsoft.com/en-us/azure/aks/quickstart-helm