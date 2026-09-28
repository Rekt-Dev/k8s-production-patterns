# Cluster Changelog

## v1.35.5 — 2026-05-12
- Upgraded control plane and workers to v1.35.5
- Updated containerd to 1.7.28
- Kernel upgraded to 6.17.0-35-generic

## v1.35.4 — 2026-04-03
- Upgraded control plane and workers to v1.35.4
- No breaking changes, routine patch

## v1.35.3 — 2026-03-01
- Upgraded control plane and workers to v1.35.3
- Updated Calico to v3.29.3 / Tigera operator v1.40.3

## v1.35.2 — 2026-02-05
- Upgraded control plane and workers to v1.35.2
- Removed Cilium after memory pressure on home lab nodes
- Reverted to Calico — lower overhead, better stability on constrained hardware

## v1.35.1 — 2026-01-10
- Upgraded control plane and workers to v1.35.1
- Installed Cilium as experimental CNI alongside Calico for eBPF testing

## v1.35.0 — 2025-12-08
- Initial cluster bootstrap — 1 control plane (k8s), 2 workers (k8s1, k8s2)
- Ubuntu 24.04.3, containerd, kubeadm
- Calico CNI via Tigera operator
- Pod CIDR: 10.244.0.0/16, Service CIDR: 10.96.0.0/12
