# Automated deployments on AWS 
## Project description
This projects includes detailed instructions on setting up automated deployments of different types of AWS infrastructure and services. A total of 5 different deployment methods have been implemented for different usage scenarios, both manually and with automation via CI/CD.

## Content
1. [Prerequisites](#prerequisities)
2. [Tools and services](#tools-and-services)
3. [Description of deployments](#description-of-deployments)

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

## Description of deployments

### Deploy to EC2 with GitHub Actions

**Description**: application deployment on one EC2 instance with automation via GitHub Actions

### Project steps for deployment

1. **Create EC2 Intance**
   - Created EC2 Instance in the AWS
   - Configured Security Group
   - Created ssh for access to EC2 Insance
2. **Copy git repository via GitHub Actions**(CI/CD automation details)
   - Created .github/worflows directory
   - Added to .github/worflows directory file deploy.yml
   - Added to deploy.yml file code and push commit 
3. **Conect to EC2 Instance via terminal**
   - ```ssh ec2-user@public_ip -i path to the key```
   - Run application code and connect to public ip
### CI/CD automation details
``` name: Deploy to AWS EC2

on:
  push:
    branches:
      - dont-deploy

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up SSH
      uses: webfactory/ssh-agent@v0.5.3
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    - name: Deploy to EC2
      run: |
        ssh -o StrictHostKeyChecking=no ec2-user@34.238.233.79 'cd /home/ec2-user/Website-ClothesShop && git pull && npm install && pkill node && nohup node app.js > output.log 2>&1 &' ```

---
