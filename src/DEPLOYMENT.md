# Deployment Guide

## Azure Container Registry Setup

This repository includes a GitHub Actions workflow that automatically builds and pushes Docker images to Azure Container Registry when code is pushed to the `main` branch.

### Required GitHub Secrets

Configure the following secrets in your GitHub repository (Settings → Secrets and variables → Actions):

- `ACR_LOGIN_SERVER`: Your Azure Container Registry login server (e.g., `myregistry.azurecr.io`)
- `ACR_USERNAME`: Username for ACR authentication
- `ACR_PASSWORD`: Password for ACR authentication
- `ENV`: Content of your `.env` file (all environment variables)

### Running the Container

The Docker image is built without the `.env` file. When running the container in production, you must provide the environment variables via the `ENV_CONTENT` environment variable:

#### Docker CLI Example
```bash
docker run -e ENV_CONTENT="$(cat .env)" -p 8000:8000 <your-acr-server>/techworkshop-app:latest
```

#### Azure Container Instances
When deploying to Azure Container Instances, set the `ENV_CONTENT` environment variable in your deployment configuration:

```bash
az container create \
  --resource-group <resource-group> \
  --name <container-name> \
  --image <your-acr-server>/techworkshop-app:latest \
  --registry-login-server <your-acr-server> \
  --registry-username <username> \
  --registry-password <password> \
  --environment-variables ENV_CONTENT="<env-file-content>" \
  --ports 8000
```

#### Azure App Service
When deploying to Azure App Service, configure the `ENV_CONTENT` environment variable in the Application Settings.

#### Kubernetes
Create a secret and mount it as an environment variable:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-env
type: Opaque
stringData:
  ENV_CONTENT: |
    VARIABLE1=value1
    VARIABLE2=value2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: techworkshop-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: <your-acr-server>/techworkshop-app:latest
        env:
        - name: ENV_CONTENT
          valueFrom:
            secretKeyRef:
              name: app-env
              key: ENV_CONTENT
```

## Security Notes

- The `.env` file is **never** committed to the repository
- Secrets are **not** embedded in the Docker image layers
- The `.env` file is created at container runtime from the `ENV_CONTENT` environment variable
- Ensure `ENV_CONTENT` is properly secured in your deployment environment
