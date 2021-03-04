# Securing Azure managed Kubernetes (AKS)

This is an automated deployment of a Fortigate to secure an Azure managed Kubernetes (AKS) in full private API endpoint, nodes and CNI.
The goal is to set the scene to help understand and secure with Fortinet solutions an AKS environment and applications.
It has been kept simple (1 Fortigate) for education and cost perspective.

Thanks to peering it can easily use more advanced Fortgiate on Azure solutions.
Contact a Fortinet representative for a completly scalable and automated solution.

The reference architecture you are going to deploy can be illustrated as follow:
![Architecture](images/SecureAKS.png)
# Bootstrap
Of course you need an Azure account with all necessary subscriptions and permissions.
On your client (laptop)
Get the code
```shell
git clone https://github.com/fortinet-solutions-cse/secured-AKS-refarch
cd secured-AKS-refarch
```

# Choose your way to cli

Choose 1 way to use the scripts/cli etc...:

* [Docker image on your client and Forticlient IPsec to the Azure fortigate](Local%20Docker%20and%20VPN.md).
* [using git, az and jq on your own shell then ssh to a provided jumphost VM inside the cluster.](JumphostUsage.md)
