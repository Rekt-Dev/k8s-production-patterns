# k8s-production-patterns

Production-grade Kubernetes security manifests, OPA Gatekeeper policies, Kyverno admission controls, Falco runtime rules, and Terraform for EKS. 


## Structure

```
├── namespaces/              # Environment isolation with Pod Security Admission labels
├── rbac/                    # Least-privilege service accounts, roles, bindings
├── network-policies/        # Default deny-all + explicit allow rules
├── deployments/             # Zero-downtime RollingUpdate with full security context
├── services/                # ClusterIP only — no unnecessary exposure
├── ingress/                 # TLS termination via cert-manager + Let's Encrypt
├── hpa/                     # CPU + memory autoscaling with scale-down stabilization
├── pdb/                     # PodDisruptionBudgets for safe node drains
├── helm/app/                # Helm chart parameterising the full stack
│
├── security/
│   ├── opa-gatekeeper/      # OPA Rego policies enforced at admission
│   ├── kyverno/             # Kyverno ClusterPolicies + Cosign image verification
│   ├── falco/               # Custom Falco runtime detection rules
│   ├── seccomp/             # Restricted seccomp profile (allowlist syscalls only)
│   └── pod-security/        # Pod Security Admission namespace labels
│
└── terraform/
    ├── eks/                 # Production EKS — private endpoint, KMS, IMDSv2, IRSA
    └── s3-backend/          # Encrypted S3 + DynamoDB state backend
```

## Security layers

### Admission Control (OPA Gatekeeper)
| Policy | Effect |
|---|---|
| No privileged containers | Blocks `privileged: true` at admission |
| Require resource limits | Rejects pods missing CPU/memory limits |
| Block `:latest` image tag | Enforces pinned image versions |

### Admission Control (Kyverno)
| Policy | Effect |
|---|---|
| Block privilege escalation | Enforces `allowPrivilegeEscalation: false` |
| Require non-root | Rejects UID 0 containers |
| Verify image signatures | Cosign keyless verification via Sigstore |

### Runtime Security (Falco)
| Rule | Detects |
|---|---|
| Shell spawned in container | Interactive shell — likely breakout attempt |
| Sensitive file read | `/etc/shadow`, `/etc/passwd`, SSH keys |
| Unexpected outbound connection | C2 beaconing, data exfil |
| Container running as root | UID 0 process detection |
| Crypto mining | Known miner process names + stratum protocol |

### Infrastructure Hardening
| Control | Implementation |
|---|---|
| Non-root containers | `runAsNonRoot: true`, `runAsUser: 1000` |
| Read-only filesystem | `readOnlyRootFilesystem: true` |
| Dropped capabilities | `capabilities.drop: ["ALL"]` |
| No privilege escalation | `allowPrivilegeEscalation: false` |
| No auto-mounted tokens | `automountServiceAccountToken: false` |
| Least-privilege RBAC | Named secret refs, namespace-scoped roles |
| Network segmentation | Default deny-all, explicit allow rules |
| TLS everywhere | cert-manager + forced HTTPS |
| Seccomp | Custom allowlist — blocks unused syscalls |
| Pod Security Admission | `restricted` profile on production namespace |

### EKS (Terraform)

| Control | Implementation |
|---|---|
| Private API endpoint | No public cluster access |
| Secrets encryption | Customer-managed KMS key |
| IMDSv2 enforced | Blocks SSRF metadata credential theft |
| Encrypted node volumes | KMS-encrypted EBS via launch template |
| IRSA | IAM Roles for Service Accounts — no node-level credentials |
| Control plane logs | API, audit, authenticator, scheduler logs to CloudWatch |
| HA NAT gateway | One per AZ — no single point of failure |
| Encrypted Terraform state | S3 + KMS + DynamoDB state lock |

## Deploy

**Apply K8s manifests:**
```bash
kubectl apply -f namespaces/
kubectl apply -f rbac/
kubectl apply -f network-policies/
kubectl apply -f security/pod-security/
kubectl apply -f deployments/
kubectl apply -f services/
kubectl apply -f ingress/
kubectl apply -f hpa/
kubectl apply -f pdb/
```

**Apply OPA Gatekeeper policies:**
```bash
# Install Gatekeeper first
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

kubectl apply -f security/opa-gatekeeper/
```

**Apply Kyverno policies:**
```bash
# Install Kyverno first
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

kubectl apply -f security/kyverno/
```

**Deploy Falco:**
```bash
helm install falco falcosecurity/falco \
  --namespace falco --create-namespace \
  --set-file falco.rulesFile=security/falco/custom-rules.yaml
```

**Provision EKS with Terraform:**
```bash
# Bootstrap state backend first
cd terraform/s3-backend
terraform init && terraform apply

# Provision EKS
cd ../eks
terraform init && terraform apply
```

**Deploy with Helm:**
```bash
helm install my-app ./helm/app \
  --namespace production \
  --set image.repository=your-registry/api \
  --set image.tag=1.0.0 \
  --set ingress.host=app.example.com
```

---


