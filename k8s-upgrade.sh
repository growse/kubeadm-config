#!/usr/bin/env bash

set +x

OLD_VERSION=$1
VERSION=$2

if (( EUID != 0 )); then
	echo "You must be root to do this." 1>&2
	exit 100
fi

if [ -z "${VERSION}" ]; then
	echo "No version supplied" 1>&2
	exit 1
fi
if [ -z "${OLD_VERSION}" ]; then
	echo "No version supplied" 1>&2
	exit 1
fi
echo "Upgrading version from ${OLD_VERSION} to ${VERSION}"

sed -i 's/'"${OLD_VERSION}"'/'"${VERSION}"'/g' /etc/apt/preferences.d/kubernetes

apt-get install kubeadm

# Check if kube-apiserver process is running
if pgrep -x "kube-apiserver" > /dev/null; then
	kubeadm config images pull --kubernetes-version ${VERSION}
	echo "This host is a Kubernetes control-plane node."
	kubeadm upgrade plan --print-config ${VERSION}
	echo -e "\n"

	read -n 1 -r -p "Shall we apply the upgrade to ${VERSION}? [y/n]: " continue
	if [[ "${continue}" != "y" ]]; then
		echo "Not continuing" 1>&2
		exit 2
	fi

	kubeadm upgrade apply --print-config -y ${VERSION}

else
	echo "This host is not a Kubernetes control-plane node."
	kubeadm upgrade node
fi

apt-get install -y kubectl kubelet

systemctl restart kubelet
