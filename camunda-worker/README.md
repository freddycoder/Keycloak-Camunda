# Camunda worker

This is a nestjs application that can be used as a worker for the Camunda BPM platform.

## Build docker image

```
docker build -t camunda-worker .
```

## Run the image

```
docker run -p 3000:3000 camunda-worker
```