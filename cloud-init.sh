#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.19
mkdir -p $HOME/.kube/
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s config > $HOME/.kube/config
sudo microk8s enable helm3

tee -a ~/.bash_aliases <<'EOF'
function helm {
        sudo microk8s helm3 "$@"
}

function kubectl {
        sudo microk8s kubectl "$@"
}
EOF
source ~/.bash_aliases

echo "# k9s..."
VERSION='0.24.2'
curl -OL https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_x86_64.tar.gz
mkdir -p tmp/
tar -C tmp/ -xvf k9s_Linux_x86_64.tar.gz
rm k9s_Linux_x86_64.tar.gz
sudo mv -f tmp/k9s /usr/local/bin
rm -rf tmp/
mkdir -p $HOME/.k9s/

echo "# az cli..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "# capz..."
git clone https://github.com/ams0/azure-managed-cluster-capz-helm.git
cd azure-managed-cluster-capz-helm
clusterctl init --infrastructure azure

echo "# complete!"