function docker-pull-images($skipPull, $buildCamunda, $pushCamunda) {
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
}