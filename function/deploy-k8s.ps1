function deploy-k8s-resource([string]$fileName, [string]$namespace) {
    # read the file
    $fileContent = Get-Content ($PWD.Path + '\' + $fileName) -Raw
    Write-Output $fileContent

    # format the file using powershell expand string
    $yaml = $ExecutionContext.InvokeCommand.ExpandString($fileContent)

    # apply the deployment using yaml variable
    Write-Output $yaml
    $yaml | kubectl apply -f - -n $namespace
}

function deploy-helm-resource($fileName, $releaseName, $releaseChart, $namespace) {
    # read the file
    $fileContent = Get-Content ($PWD.Path + '\' + $fileName) -Raw

    # format the file using powershell expand string
    $yaml = $ExecutionContext.InvokeCommand.ExpandString($fileContent)

    # apply the deployment
    if (-not $skipPull) {
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm repo update
    }
    # check if the release already exists
    $release = helm list -n $namespace | Select-String $releaseName
    Write-Output "Release: $release"
    if ($release) {
        Write-Output "Upgrading keycloak"
        $yaml | helm upgrade $releaseName $releaseChart -n $namespace -f -
    } else {
        Write-Output "Installing keycloak"
        $yaml | helm install $releaseName $releaseChart -n $namespace -f -
    }
}