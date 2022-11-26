# Keycloak-Camunda
A repos to experiment with Keycloak and Camunda in Kubernetes

## Deploy

```
.\deploy.ps1
```

## Links

- Keycloak: http://localhost:32000
- Camunda: http://localhost:32001/camunda-welcome/

## Manuel instruction

Once the deployment is done, you need to manually import the realm file `realm-export.json` into Keycloak.

Then you need to create a user, give it a password and add it to the `camunda-admin` group.

The last manuel step is to create a deployment using postman and the product_management.bpmn file.

You can use this postman collection in this repos to do so.

## Delete deployment

```
.\delete-namespace.ps1
```