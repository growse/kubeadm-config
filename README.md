# Some notes and handy `kubeadm` commands

## Get a node join token

`kubeadm token create --print-join-command --config kubeadm-config.yaml`

## Refresh the API server certs (because you added a new SAN or something)

1. Remove the old cert/key in /etc/kubernetes/pki/
2. `kubeadm init phase certs apiserver --config kubeadm-config.yaml`
3. Kill the API server pod


## Check and approve kubelet CSRs

1. `kubectl get csr`
2. `kubectl certificate approvate <csr-name>`
