# Aegis Pi GitOps

This repository is the GitOps source of truth watched by the EKS Hub Argo CD.

For the MVP, existing `factory-a` local K3s workloads such as `ai-apps`,
Longhorn, MetalLB, and monitoring remain locally managed on the edge cluster.
This repository starts with a small smoke workload so the deployment pipeline
can be validated without disturbing the operating edge baseline.

## Layout

```text
charts/
  aegis-spoke/
    Chart.yaml
    values.yaml
    templates/
envs/
  factory-a/
    values.yaml
  factory-b/
    values.yaml
  factory-c/
    values.yaml
applicationsets/
  aegis-spoke-applicationset.yaml
```

## MVP Boundary

```text
Managed by factory-a local K3s baseline:
  ai-apps
  monitoring
  longhorn-system
  metallb-system
  failover/failback local operations

Managed by EKS Hub Argo CD in M3:
  aegis-spoke-smoke

Post-MVP candidate:
  ai-apps Helm migration with factory-a manual sync and prune disabled
```

## Local Render Check

```bash
helm template aegis-spoke charts/aegis-spoke -f envs/factory-a/values.yaml
helm template aegis-spoke charts/aegis-spoke -f envs/factory-b/values.yaml
helm template aegis-spoke charts/aegis-spoke -f envs/factory-c/values.yaml
```

## CI Boundary

This repository validates GitOps manifests only.

```text
Included:
  Helm lint
  Helm template render checks for factory-a/b/c
  YAML syntax validation

Excluded:
  Docker build
  ECR push
  kubectl apply
  Argo CD sync
```

Image build, ECR push, manifest tag updates, and deployment verification are
handled by later M3 issues.
