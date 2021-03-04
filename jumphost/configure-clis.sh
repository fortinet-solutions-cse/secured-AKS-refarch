#!/bin/bash -e
# Script to configure a jumphost for the demos
sudo apt-get update
export  DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg python3-pip software-properties-common
curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
export AZ_REPO=$(lsb_release -cs)
sudo sh -c "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main\" > /etc/apt/sources.list.d/azure-cli.list"
curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
curl  https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb 
sudo dpkg -i packages-microsoft-prod.deb
sudo sh -c "echo \"deb https://apt.kubernetes.io/ kubernetes-xenial main\"  > /etc/apt/sources.list.d/kubernetes.list"
sudo add-apt-repository universe
sudo apt-get update && (sudo apt-get -y install bash-completion kubectl openssh-client apache2-utils  jq azure-cli sudo  wget zile byobu ccze powershell)&& \
        sudo sh -c "kubectl completion bash >/etc/bash_completion.d/kubectl"
# Must use python3 or the fortios ansible modules do not work
sudo pip3 --no-cache-dir install --upgrade pip
sudo pip3 --no-cache-dir install ansible
# see https://galaxy.ansible.com/fortinet/fortios
ansible-galaxy collection install fortinet.fortios
az extension add --name aks-preview
