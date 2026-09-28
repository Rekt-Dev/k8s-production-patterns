# Calico Install — Tigera Operator

CNI: Calico v3.29.3 via Tigera Operator v1.40.3

## Install Tigera operator

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml
```

## Apply custom resources

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/custom-resources.yaml
```

## Verify

```bash
watch kubectl get pods -n calico-system
kubectl get tigerastatus
```

Wait for all pods Running and tigerastatus Available before joining workers.

## Join worker nodes

On each worker (k8s1 192.168.1.111, k8s2 192.168.1.112):

```bash
kubeadm join 192.168.1.110:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

## Verify cluster

```bash
kubectl get nodes -o wide
# All nodes Ready with Calico CNI
```
