param(
    [bool]$skipPull,
    [bool]$buildCamunda,
    [bool]$pushCamunda,
    [string]$namespace = "keycloak-camunda"
)

$camudaBaseImg = "camunda/camunda-bpm-platform:run-7.18.0"

if (-not $skipPull) {
    docker pull bitnami/keycloak:latest
    docker pull $camudaBaseImg
    docker pull postgres:latest
    docker pull erabliereapi/camunda-keycloak:latest
    docker pull busybox:1.28
}

if ($buildCamunda) {
    docker build -t erabliereapi/camunda-keycloak:latest `
                 .\docker\. `
                 -f .\docker\camunda-keycloak.dockerfile `
                 --build-arg CAMUNDA_BASE_IMG=$camudaBaseImg

    if ($pushCamunda) {
        docker push erabliereapi/camunda-keycloak:latest
    }
}

kubectl apply -f .\k8s\namespace.yaml
kubectl apply -f .\k8s\postgres-keycloak.yaml -n $namespace
kubectl apply -f .\k8s\postgres-camunda.yaml -n $namespace
kubectl apply -f .\k8s\keycloak.yaml -n $namespace
kubectl apply -f .\k8s\camunda-app.yaml -n $namespace
kubectl apply -f .\k8s\camunda-api.yaml -n $namespace