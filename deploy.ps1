param(
    [bool]$skipPull,
    [bool]$buildCamunda,
    [bool]$pushCamunda,
    [string]$namespace = "keycloak-camunda",
    [bool]$restartCamunda
)

. .\function\docker-pull.ps1
. .\function\deploy-k8s.ps1
. .\secrets\secrets.ps1

docker-pull-images -skipPull $skipPull -buildCamunda $buildCamunda -pushCamunda $pushCamunda

# create namespace
kubectl apply -f .\k8s\namespace.yaml

# deploy database
deploy-k8s-resource -fileName "k8s\postgres-keycloak.yaml" -namespace $namespace
deploy-k8s-resource -fileName "k8s\postgres-camunda.yaml" -namespace $namespace

# deploy keycloak
python .\remove_id_from_keycloak_export.py .\realm-export.json .\realm-export-edit.json
kubectl delete secret keycloak-config-cli-import -n $namespace
kubectl create secret generic keycloak-config-cli-import --from-file=./realm-export-edit.json -n $namespace
# deploy the helm chart
deploy-helm-resource -fileName "k8s\keycloak-values.yaml" -releaseName "keycloak" -releaseChart "bitnami/keycloak" -namespace $namespace

# deploy camunda
deploy-k8s-resource -fileName "k8s\camunda-app.yaml" -namespace $namespace
deploy-k8s-resource -fileName "k8s\camunda-api.yaml" -namespace $namespace

if ($restartCamunda) {
    kubectl rollout restart deployment/camunda-app -n $namespace
    kubectl rollout restart deployment/camunda-api -n $namespace
}