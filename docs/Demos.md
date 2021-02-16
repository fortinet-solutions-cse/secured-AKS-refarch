# Follow along demos.

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

