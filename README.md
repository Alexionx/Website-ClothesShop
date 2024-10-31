# Automated deployments on AWS 
## Project description
This projectи includes detailed instructions on setting up automated deployments of different types of AWS infrastructure and services. A total of 5 different deployment methods have been implemented for different usage scenarios, both manually and with automation via CI/CD.

## Content
1. [Prerequisites](#prerequisities)
2. [Tools and services](#tools-and-services)
3. [Description of deployments](#description-of-deployments)
4. [Project settings for each deployment](#project-settings-for-each-deployment)
5. [CI/CD automation details](#CI/CD-automation-details)

---

### Prerequisites

To successfully use this project, you will need:
- An AWS account and an IAM-created user with appropriate permissions
- Configured AWS CLI profile
- Knowledge of the basics AWS(EC2, ECS, S3, ECR), Terraform, Docker, GitHub Actions

### Tools and services

- **Terraform** - to manage infrastructure as code
- **GitHub Actions** - for CI/CD process
- **Docker** and **ECS** - for containerization and orchestration
- **Amazon EC2** - for server solutions
- **S3** and **ECR** - for storing Terraform states and storing Docker Images

---

### Description of deployments

1. **Deploy to EC2** - Describes how to deploy a simple application to a single EC2 instance using GitHub Actions

---

### Project settings for each deployment

---

### CI/CD automation details


