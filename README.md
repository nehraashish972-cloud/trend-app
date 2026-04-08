# Trend App - Production Deployment

**Author:** Ashish Nehra  
**Date:** April 09, 2026

## Architecture
- **EC2**: Jenkins CI/CD Server
- **EKS**: Kubernetes Cluster (2 nodes)
- **Docker**: Containerized React App
- **Terraform**: Infrastructure as Code

## Application URLs
- App LoadBalancer: a5545670064694981b8baae069c83fd1-1306030366.ap-south-1.elb.amazonaws.com
- Grafana Monitoring: a7cbcc5cc1e334967944b561270bc6f6-91628484.ap-south-1.elb.amazonaws.com:32699

## Pipeline Flow
1. GitHub push triggers Jenkins webhook
2. Jenkins pulls code
3. Docker builds image
4. Pushes to DockerHub (asheesh972/trend-app)
5. Deploys to EKS cluster

## Setup Instructions
1. Clone repo: git clone https://github.com/nehraashish972-cloud/trend-app.git
2. Terraform: cd terraform && terraform init && terraform apply
3. EKS: eksctl create cluster --name trend-cluster --region ap-south-1
4. Jenkins: http://13.201.37.75:8080

## Kubernetes LoadBalancer ARN
a5545670064694981b8baae069c83fd1-1306030366.ap-south-1.elb.amazonaws.com

## Monitoring
Grafana + Prometheus installed via Helm
