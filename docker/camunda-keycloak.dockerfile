# Get Camunda-run as base image
FROM camunda/camunda-bpm-platform:run-7.17.0

# The Version of the Keycloak Identity Provider to use
ENV IDENTITY_PROVIDER_VERSION=7.17.0

# COPY the camunda-keycloak yml file to the camunda conf folder
COPY config/camunda-keycloak/. /camunda/configuration

# Add Keycloak Identity Provider
USER camunda
RUN wget https://artifacts.camunda.com/artifactory/camunda-bpm-community-extensions/org/camunda/bpm/extension/camunda-platform-7-keycloak-run/$IDENTITY_PROVIDER_VERSION/camunda-platform-7-keycloak-run-$IDENTITY_PROVIDER_VERSION.jar -P /camunda/configuration/userlib