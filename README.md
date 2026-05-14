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

## Image Registry Boundary

Container images for Spoke workloads are stored in AWS ECR, not Docker Hub.

```text
Registry:
  611058323802.dkr.ecr.ap-south-1.amazonaws.com

Current ECR repository:
  aegis/edge-agent

Deployment image examples:
  611058323802.dkr.ecr.ap-south-1.amazonaws.com/aegis/edge-agent:sha-<7-char-git-sha>
  611058323802.dkr.ecr.ap-south-1.amazonaws.com/aegis/edge-agent:main
  611058323802.dkr.ecr.ap-south-1.amazonaws.com/aegis/edge-agent:latest
```

The code repository builds and pushes images to ECR. This GitOps repository
stores only the desired image reference in Helm values. EKS Hub Argo CD reads
that desired state and syncs it to the registered Spoke cluster over the
Tailscale control path.

Raspberry Pi K3s nodes are not EKS nodes, so they do not inherit an ECR pull
role. Spoke clusters must receive an `imagePullSecret` such as `ecr-registry`
in the target namespace before ECR images can be pulled.

```text
code repo
  -> docker build
  -> ECR push
  -> update envs/<factory>/values.yaml image tag
  -> EKS Hub Argo CD sync
  -> Tailscale
  -> Raspberry Pi K3s rollout
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
  ECR imagePullSecret render validation
  Workflow boundary validation

Excluded:
  Docker build
  ECR push
  kubectl apply
  Argo CD sync
```

Image build, ECR push, manifest tag updates, and deployment verification are
handled by later M3 issues.
