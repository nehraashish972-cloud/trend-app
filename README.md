# 🛍️ Trend Store — CI/CD Pipeline with Jenkins, EKS, Docker, Terraform & Monitoring

![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-blue)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED)
![EKS](https://img.shields.io/badge/Orchestration-EKS-FF9900)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)
![Monitoring](https://img.shields.io/badge/Monitoring-Grafana%20%2B%20Prometheus-orange)

---

## 📌 Project Overview

**Trend Store** is a production-grade e-commerce application deployed using a fully automated DevOps pipeline on AWS.

This project demonstrates:
- Automated CI/CD pipeline using Jenkins
- Containerization with Docker
- Kubernetes orchestration on Amazon EKS
- Infrastructure as Code using Terraform
- Real-time monitoring with Prometheus and Grafana

---

## 🏗️ ArchitectureDeveloper pushes code
↓
GitHub Repo
↓ (webhook trigger)
Jenkins
↓
Docker Build
↓
Push to ECR
↓
Deploy to EKS
↓
App Running on Kubernetes
↓
Prometheus scrapes metrics
↓
Grafana shows dashboards
---

## 🧰 Tech Stack

| Tool | Purpose |
|------|---------|
| **Jenkins** | CI/CD automation — build, test, deploy |
| **Docker** | Containerize the application |
| **Amazon EKS** | Managed Kubernetes cluster on AWS |
| **Amazon ECR** | Docker image registry |
| **Terraform** | Infrastructure as Code |
| **Prometheus** | Metrics collection from Kubernetes |
| **Grafana** | Dashboard and visualization |
| **GitHub** | Source code and webhook trigger |

---

## 📁 Project Structure  trend-app/
├── Jenkinsfile              # CI/CD pipeline stages
├── Dockerfile               # Docker image instructions
├── k8s/                     # Kubernetes manifests
│   ├── deployment.yaml      # App deployment
│   ├── service.yaml         # LoadBalancer service
│   └── ingress.yaml         # Ingress rules
├── terraform/               # Infrastructure as Code
│   ├── main.tf              # EKS + VPC setup
│   ├── variables.tf         # Input variables
│   └── outputs.tf           # Output values
├── dist/                    # Built application
└── .gitignore               # Excludes secrets and large files  ---

## 🚀 CI/CD Pipeline Stages  Stage 1: Checkout Code from GitHub
Stage 2: Install Dependencies
Stage 3: Build Docker Image
Stage 4: Push Image to Amazon ECR
Stage 5: Update Kubeconfig
Stage 6: Deploy to EKS Cluster
Stage 7: Verify Deployment  ---

## ☁️ Infrastructure — Terraform

All AWS infrastructure is created via Terraform code.

**Resources Created:**
- VPC with public and private subnets
- EKS Cluster: `trend-store-cluster` (region: `ap-south-1`)
- Node Group: `m7i-flex.large` instances
- IAM Roles for EKS and Node Group
- Security Groups

**Commands:**
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

> ⚠️ Never commit terraform.tfvars — it contains secrets!

---

## 📊 Monitoring — Prometheus + Grafana

### Prometheus
- Deployed inside EKS in `monitoring` namespace
- Scrapes metrics from all pods and nodes automatically

### Grafana
- Accessible via AWS Load Balancer URL
- Login: `admin` / `Admin@123`

### Dashboard Panels

| Panel | PromQL Query |
|-------|-------------|
| CPU Usage | `sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod)` |
| Memory Usage | `sum(container_memory_usage_bytes{namespace="default"}) by (pod)` |
| Pod Status | `kube_pod_status_phase{namespace="default"}` |

---

## ⚙️ Prerequisites

- AWS Account with admin IAM access
- AWS CLI installed and configured
- kubectl installed
- eksctl installed
- Terraform installed
- Docker installed
- Jenkins (running as Docker container)

---

## 🔧 Complete Setup Guide

### Step 1 — Clone the Repository
```bash
git clone https://github.com/nehraashish972-cloud/trend-app.git
cd trend-app
```

### Step 2 — Configure AWS
```bash
aws configure
# AWS Access Key ID: your-key
# AWS Secret Access Key: your-secret
# Default region: ap-south-1
# Default output: json
```

### Step 3 — Create Infrastructure
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### Step 4 — Connect to EKS
```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name trend-store-cluster

kubectl get nodes
```

### Step 5 — Deploy Monitoring Stack
```bash
kubectl create namespace monitoring

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm install prometheus \
  prometheus-community/kube-prometheus-stack \
  -n monitoring

kubectl get svc -n monitoring
```

### Step 6 — Run Jenkins
```bash
docker run -d --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### Step 7 — Configure Jenkins
1. Open `http://<your-ec2-ip>:8080`
2. Install suggested plugins
3. Add AWS credentials in Jenkins Credentials
4. Create Pipeline job → point to this repo
5. Add GitHub webhook: `http://<jenkins-ip>:8080/github-webhook/`

---

## 🔐 Security Best Practices

- `.terraform/` folder excluded from git (contains large provider binaries)
- `terraform.tfvars` excluded (contains AWS secrets)
- `*.pem` key files excluded
- AWS credentials stored in Jenkins Credentials Store only
- Never hardcode secrets in Jenkinsfile

---

## 🐛 Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| `aws: command not found` | Install AWS CLI v2 |
| `kubectl: command not found` | Install kubectl |
| Partial credentials error | Run `aws configure` again |
| EKS unreachable | Run `aws eks update-kubeconfig` |
| Jenkins can't push to ECR | Add AWS credentials in Jenkins |

---

## 👨‍💻 Author

**Ashish Nehra**
- GitHub: [@nehraashish972-cloud](https://github.com/nehraashish972-cloud)
- Email: nehraashish972@gmail.com

---

## 📄 License

This project is built for learning and portfolio purposes.
