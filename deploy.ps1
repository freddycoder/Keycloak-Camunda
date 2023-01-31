param(
    [bool]$skipPull,
    [bool]$buildCamunda,
    [bool]$pushCamunda,
    [string]$namespace = "keycloak-camunda",
    [bool]$restartCamunda
)

$camudaBaseImg = "camunda/camunda-bpm-platform:run-7.18.0"

if (-not $skipPull) {
    docker pull bitnami/keycloak:latest
    docker pull bitnami/keycloak-config-cli:latest
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

# create namespace
kubectl apply -f .\k8s\namespace.yaml

# deploy database
kubectl apply -f .\k8s\postgres-keycloak.yaml -n $namespace
kubectl apply -f .\k8s\postgres-camunda.yaml -n $namespace

# deploy keycloak
# create the keycloak configmap from realm-export.json
python .\remove_id_from_keycloak_export.py .\realm-export.json .\realm-export-edit.json
kubectl delete configmap keycloak-config-cli-import -n $namespace
kubectl create configmap keycloak-config-cli-import --from-file=./realm-export-edit.json -n $namespace
kubectl apply -f .\k8s\keycloak.yaml -n $namespace
kubectl apply -f .\k8s\keycloak-config-cli.yaml -n $namespace

# deploy camunda
kubectl apply -f .\k8s\camunda-app.yaml -n $namespace
kubectl apply -f .\k8s\camunda-api.yaml -n $namespace

if ($restartCamunda) {
    kubectl rollout restart deployment/camunda-app -n $namespace
    kubectl rollout restart deployment/camunda-api -n $namespace
}