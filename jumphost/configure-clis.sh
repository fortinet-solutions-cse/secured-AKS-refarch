#!/bin/bash -e
# Script to configure a jumphost for the demos
apt-get update
export  DEBIAN_FRONTEND=noninteractive
apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg python3-pip software-properties-common
curl -sL https://packages.microsoft.com/keys/microsoft.asc |  apt-key add -
AZ_REPO=$(lsb_release -cs); echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list
curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
curl  https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb ; dpkg -i packages-microsoft-prod.deb
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main"  > /etc/apt/sources.list.d/kubernetes.list
add-apt-repository universe
apt-get update && (apt-get -y install bash-completion kubectl openssh-client apache2-utils  jq azure-cli sudo  wget zile byobu ccze powershell)&& \
        kubectl completion bash >/etc/bash_completion.d/kubectl
# Must use python3 or the fortios ansible modules do not work
pip3 --no-cache-dir install ansible
# see https://galaxy.ansible.com/fortinet/fortios
ansible-galaxy collection install fortinet.fortios
az extension add --name aks-preview
chown -R azureuser:azureuser  ~/.azure/