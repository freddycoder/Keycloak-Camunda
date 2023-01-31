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

Once the deployment is done, you need to create a user inside the camunda realm inside keycloak, give it a password and add it to the `camunda-admin` group.

The last manuel step is to create a deployment if the the product_management.bpmn file inside camunda.

You can use this postman collection in this repos to do so.

## Delete deployment

```
.\delete-namespace.ps1
```