# Hands on demos

This document simple examples that are ready to use to test the differents protections or this Reference Architecture and capabiliites of the Fortigate to protect the cluster, apps and app traffic.

This is made to be fully compatible with AKS Tutorial and just add the security checks in-traffic provided by Fortigate.
You can follow the Tutorial with or without this refarch.




## Simple demo app



## log checks

## Nodes traffic

## Antivirus


## internal LB and VIP

## Fortigate as a LoadBalancer










git clone https://github.com/fortinet/k8s-fortigate-ctrl

# In cluster controller
To run the controller in cluster with the good role/serviceaccount etc.
```shell
kubectl apply -f fortigates.fortinet.com.yml 
kubectl apply -f lb-fgts.fortigates.fortinet.com.yml 
kubectl create namespace fortinet
kubectl apply -n fortinet -f serviceaccount.yaml -f ctrl-role.yml -f rolebinding.yaml 
kubectl apply -n fortinet -f deployment.yaml
```


Annotation or config-map on the controllers for the FGT ip.

# usage
# Tips
To have a nice monitoring of kubectl states

````shell script
watch -c "kubectl get pods,lb-fgt,svc -o wide|ccze -A"
````

