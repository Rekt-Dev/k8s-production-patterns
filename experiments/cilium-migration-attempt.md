# Cilium Migration Attempt

**Date**: January 2026  
**Outcome**: Reverted to Calico

## Motivation

Wanted to evaluate Cilium as an alternative CNI for:
- eBPF-based NetworkPolicy enforcement (faster than iptables)
- Hubble observability — layer 7 visibility without a service mesh
- Native support for CiliumNetworkPolicy (more expressive than standard NetworkPolicy)

## What was tested

- Installed Cilium alongside existing Calico setup in isolated `cilium-test` namespace
- Tested basic L3/L4 policy enforcement
- Attempted to enable Hubble UI for flow visualization

## Why reverted

Memory pressure. The eBPF maps, Hubble relay, and Cilium agent DaemonSet caused significant RAM consumption across all 3 nodes. On home lab hardware with limited memory, this caused node instability and eventually took down the host.

Calico with Tigera operator provides equivalent NetworkPolicy enforcement with significantly lower overhead — the right choice for a resource-constrained 3-node home lab.

## Conclusion

Cilium is the right call for production clusters with proper hardware. For this environment, Calico wins on stability and resource efficiency. The `cilium-test` namespace remains as a reminder.

## References
- https://docs.cilium.io/en/stable/
- https://docs.tigera.io/calico/latest/
