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
python .\remove_id_from_keycloak_export.py .\realm-export.json .\realm-export-edit.json
kubectl delete configmap keycloak-config-cli-import -n $namespace
kubectl create configmap keycloak-config-cli-import --from-file=./realm-export-edit.json -n $namespace
if (-not $skipPull) {
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
}
# check if the release already exists
$release = helm list -n $namespace | Select-String "keycloak"
Write-Output "Release: $release"
if ($release) {
    Write-Output "Upgrading keycloak"
    helm upgrade keycloak bitnami/keycloak -n $namespace -f k8s/keycloak-values.yaml
} else {
    Write-Output "Installing keycloak"
    helm install keycloak bitnami/keycloak -n $namespace -f k8s/keycloak-values.yaml
}

# deploy camunda
kubectl apply -f .\k8s\camunda-app.yaml -n $namespace
kubectl apply -f .\k8s\camunda-api.yaml -n $namespace

if ($restartCamunda) {
    kubectl rollout restart deployment/camunda-app -n $namespace
    kubectl rollout restart deployment/camunda-api -n $namespace
}