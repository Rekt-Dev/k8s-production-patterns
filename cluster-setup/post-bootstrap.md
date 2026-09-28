# Post-Bootstrap Setup

Steps taken after cluster was up and all nodes Ready.

## Metrics server

Required for `kubectl top` and HPA to function:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

On a home lab without valid TLS certs, patch to skip TLS verification:

```bash
kubectl patch deployment metrics-server -n kube-system \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

## OPA Gatekeeper

Policy enforcement at admission:

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

Verify:

```bash
kubectl get pods -n gatekeeper-system
```

## ingress-nginx

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.0/deploy/static/provider/baremetal/deploy.yaml
```

## Namespaces

```bash
kubectl create namespace rekt-prod-env
```

## kubeconfig for local access

Copy `/etc/kubernetes/admin.conf` to local machine `~/.kube/config` and update the server IP.
