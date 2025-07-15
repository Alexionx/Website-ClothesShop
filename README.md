# Automated Kubernetes deployments on AWS using GitOps
## Project description
This project uses Kubespray to deploy a Kubernetes cluster on AWS, with Flux implementing GitOps-based automated cluster and application management.

## Content
1. [Prerequisites](#prerequisities)
2. [Tools and services](#tools-and-services)
3. [Description of deployments](#description-of-deployments)

---

### Prerequisites

To successfully use this project, you will need:
- An AWS account and an IAM-created user with appropriate permissions
- A configured AWS CLI profile
- Basic knowledge of AWS (EC2, IAM), Kubernetes, Kubespray, Terraform, Git, GitHub Actions, and Flux (GitOps)

### Tools and services

- **Kubespray** - to deploy a production-ready Kubernetes cluster on AWS EC2
- **Flux repository (GitOps)** - for automated cluster and application management via Git
- **Repository with Code** - contains a GitHub Actions workflow that builds and pushes Docker images by tag
- **GitHub Actions** - for CI/CD workflows
- **Docker Hub** - to store and distribute built Docker images
- **Amazon EC2** - to host Kubernetes nodes

---

## Description of deployment

### Deployment Design Overview

**Description**: This instruction implements a multi-stage deployment pipeline for delivering containerized applications to AWS infrastructure with full automation and GitOps practices.

### The process is broken down into the following stages:

### Stage 1: Build and Push Docker Image

1. **What’s implemented:**
   - GitHub repository contains application code and a production-ready Dockerfile
   - GitHub Actions workflow defined in .github/workflows/deploy_container.yml
   - Secrets configured in GitHub:
      - DOCKERHUB_USERNAME
      - DOCKERHUB_TOKEN
2. **Workflow logic:**
    **On every new Git tag, GitHub Actions:**
     - Check out the repository using actions/checkout
     - Set up Docker Buildx to support multi-platform builds
     - Log in to Docker Hub using stored GitHub Secrets
     - Extract the Git tag and store it as TAG Build and push the Docker image to Docker Hub

### Workflow
```
name: Build and Push Docker Image

on:
  push:
    branches: ["k8s"]
    tags:
      - 'v*'

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract tag version
        id: vars
        run: echo "TAG=${GITHUB_REF#refs/tags/}" >> $GITHUB_ENV

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/clothesshop:${{ env.TAG }}
```
### Stage 2: Infrastructure Provisioning – Create EC2 Virtual Machines

**Tools:** AWS EC2

**Description:**
At this stage, virtual machines are provisioned in AWS to serve as nodes for the future Kubernetes cluster.
Infrastructure as Code is used to ensure reproducibility and automation.

1. **Provisioned resources:**
- master-01 – primary control-plane node for Kubernetes
- worker-01 – worker node to run application workloads

2. **Minimal recommended instance types:**
- t2.medium or t3.medium (2 vCPU, 4 GB RAM) for both nodes

3. **Key setup steps include:**
- Launch two EC2 instances in the AWS Console
- Use SSH tunneling for access
- Configure Security Groups to allow:
  - Port 22 for SSH access
  - Port 6443 for Kubernetes API
  - Port 80 for HTTP traffic
  - Port 443 for HTTPS traffic
- Create and use a shared SSH key pair for provisioning and remote access
- Assign instance names (master-01, worker-01) for clarity during cluster setup
