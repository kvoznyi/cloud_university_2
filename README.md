# Workout Planner — Cloud Labs Project

A unified cloud computing project covering 5 university lab works (LR1–LR5) using **Azure** as the single cloud provider and **Terraform** for Infrastructure as Code.

## Project Overview

**Workout Planner** is a web application that:
- Provides a fitness dashboard (ASP.NET Core)
- Uses ML to recognize physical activities and recommend workouts
- Is containerized with Docker
- Deployed to Azure (VM, App Service, AKS)
- Monitored with Prometheus + Grafana

## Lab Coverage

| Lab | Topic | Key Components |
|-----|-------|----------------|
| LR1 | System Architecture | Architecture diagram, service descriptions |
| LR2 | Containerization & VM Deployment | ASP.NET Core, Docker, ACR, Azure VM |
| LR3 | ML Service | Activity recognition model, FastAPI prediction API |
| LR4 | Managed Service Deployment | Azure App Service |
| LR5 | Monitoring & Kubernetes | AKS, Prometheus, Grafana, Helm, stress testing |

## Tech Stack

- **App**: ASP.NET Core 10 (MVC)
- **ML**: Python, scikit-learn, FastAPI
- **Containers**: Docker
- **IaC**: Terraform
- **Cloud**: Azure (Resource Group, VNet, ACR, VM, App Service, AKS, Azure ML)
- **Monitoring**: Prometheus, Grafana, Helm
- **Stress Testing**: hey / k6

## Repository Structure

```
workout-planner/
├── app/web/              # ASP.NET Core web application
├── ml/
│   ├── training/         # ML training pipeline
│   └── api/              # FastAPI prediction service
├── infra/
│   ├── core/             # Resource Group, VNet, NSG
│   ├── registry/         # Azure Container Registry
│   ├── app-vm/           # VM deployment
│   ├── app-service/      # App Service (managed)
│   ├── ml/               # Azure ML Workspace
│   ├── k8s/              # AKS cluster
│   └── monitoring/       # Prometheus + Grafana (Helm)
├── scripts/              # Build, deploy, train, test scripts
├── docs/                 # Architecture diagrams
└── reports/              # Lab reports (LR1–LR5)
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.5
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
- [Docker](https://www.docker.com/)
- [.NET 10 SDK](https://dotnet.microsoft.com/)
- [Python 3.11+](https://www.python.org/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)

### Step-by-step

```bash
# 1. Login to Azure
az login

# 2. Deploy core infrastructure
cd infra/core && terraform init && terraform apply

# 3. Deploy container registry
cd ../registry && terraform init && terraform apply

# 4. Build and push app image
cd ../../ && ./scripts/build-and-push.sh

# 5. Deploy to VM (LR2)
cd infra/app-vm && terraform init && terraform apply

# 6. Train ML model (LR3)
./scripts/train-model.sh

# 7. Deploy to App Service (LR4)
cd infra/app-service && terraform init && terraform apply

# 8. Deploy AKS + monitoring (LR5)
cd infra/k8s && terraform init && terraform apply
cd ../monitoring && terraform init && terraform apply
./scripts/load-test.sh

# 9. CLEANUP
# Destroy in reverse order to avoid dependency issues
```