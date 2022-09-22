param([bool]$skipPull)

if (-not $skipPull) {
    docker pull bitnami/keycloak:latest
    docker pull camunda/camunda-bpm-platform:latest
    docker pull postgres
}

kubectl apply -f .\keycloak.yaml
kubectl apply -f .\camunda.yaml
kubectl apply -f .\postgres.yaml