#!/usr/bin/env bash

export AWS_ACCOUNT_ID=${3}
export AWS_DEFAULT_REGION=${2}

# write cluster-autoscaler-chart-values.yaml
cat <<EOF > cluster-autoscaler-chart-values.yaml
awsRegion: ${2}

rbac:
  create: true
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${1}-cluster-autoscaler"

autoDiscovery:
  clusterName: ${1}
  enabled: true

extraArgs:
  skip-nodes-with-local-storage: false
  expander: least-waste
  balance-similar-node-groups: true
  skip-nodes-with-system-pods: false

EOF

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm template ${1} stable/cluster-autoscaler --namespace kube-system  --values=cluster-autoscaler-chart-values.yaml > cluster-autoscaler-deployment.yaml
kubectl apply -n kube-system -f cluster-autoscaler-deployment.yaml
