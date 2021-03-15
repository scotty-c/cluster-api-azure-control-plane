#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# motd ..."
curl -L -o 01-custom 'https://raw.githubusercontent.com/scotty-c/cluster-api-dev/main/01-custom'
mv 01-custom /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/01-custom

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.20
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
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.14/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl

echo "# complete!"