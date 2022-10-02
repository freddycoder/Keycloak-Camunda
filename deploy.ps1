param(
    [bool]$skipPull,
    [bool]$buildCamunda,
    [bool]$pushCamunda,
    [string]$namespace = "keycloak-camunda"
)

if (-not $skipPull) {
    docker pull bitnami/keycloak:latest
    docker pull camunda/camunda-bpm-platform:run-7.17.0
    docker pull postgres:latest
    docker pull erabliereapi/camunda-keycloak:latest
    docker pull busybox:1.28
}

if ($buildCamunda) {
    docker build -t erabliereapi/camunda-keycloak:latest .\docker\. -f .\docker\camunda-keycloak.dockerfile

    if ($pushCamunda) {
        docker push erabliereapi/camunda-keycloak:latest
    }
}

kubectl apply -f .\namespace.yaml
kubectl apply -f .\postgres-keycloak.yaml -n $namespace
kubectl apply -f .\postgres-camunda.yaml -n $namespace
kubectl apply -f .\keycloak.yaml -n $namespace
kubectl apply -f .\camunda-app.yaml -n $namespace
kubectl apply -f .\camunda-api.yaml -n $namespace