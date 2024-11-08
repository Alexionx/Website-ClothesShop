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
        ssh -o StrictHostKeyChecking=no ec2-user@34.238.233.79 'cd /home/ec2-user/Website-ClothesShop && git pull && npm install && pkill node && nohup node app.js > output.log 2>&1 &' 
```

---

## Deploy to EC2 with Nginx

**Description**: application deployment on one EC2 instance with automation via GitHub Actions and with Nginx

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
   - Open nginx configuration ``` sudo nano /etc/nginx/nginx.conf```
   ## Change nginx.conf
   
   ```
   server {
    listen 80;
    server_name ${EC2_PUBLIC_IP};  

    location / {
        proxy_pass http://localhost:3000;  # my node.js application running in this port
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        # Додаткові заголовки для безпеки (опційно)
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

     # Статичні файли (CSS, JS, зображення) з папки 'public'
    location /public/ {
        alias /home/ec2-user/Website-ClothesShop/public/;  # Шлях до папки 'public' на сервері
        access_log off;
        expires max;
    }

    # ejs шаблони папки views
    location /views/ {
        alias /home/ec2-user/Website-ClothesShop/views/;  # Шлях до папки 'views'
        autoindex on;
    }
   }```

- Restart nginx ``` sudo systemctl restart nginx ```

**As a result**: we have an app that always works without an additional launch

### CI/CD automation details

```
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
        ssh -o StrictHostKeyChecking=no ec2-user@44.202.248.99 << 'EOF'
          cd /home/ec2-user/Website-ClothesShop
          git pull
          npm install

          # Перевіряємо Nginx конфігурацію
          sudo nginx -t

          # Перезапускаємо Nginx
          sudo systemctl restart nginx

          # Перезапускаємо додаток через Nginx
          pkill node
          nohup node app.js > output.log 2>&1 &
        EOF
```

---

## Deploy to EC2 via Terraform

**Description**: application deployment on one EC2 instance with automation via Terraform

1. **File settings main.tf**
   - Created S3 bucket to store state terraform configiration
   ## main.tf file
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
      bucket = "application-bucket-test" # назва бакету 
      key = "terraform/terraform.tfstate" # створює файлову систему terraform де буде находитися мій файл
      region = "us-east-1" # вказуєм регіон
      encrypt = true # шифрування файлу 
  }

}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00f251754ac5da7f0"
  instance_type = "t2.micro"
  key_name      = "devops-practice-test-key"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id] # Прив'язка Security Group  

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "WebApplication"
  }
}

# посилаюсь на існуючу security group

data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["new_app_security_group"]  # Вкажіть ім'я вашої існуючої групи безпеки
  }
}
```   
**As a result**: we have Infrastructure as Code

### CI/CD automation details
```
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

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Install Terraform
      uses: hashicorp/setup-terraform@v1

    - name: Initialize Terraform
      run: terraform init
      working-directory: ./terraform  # вказали директорію, де знаходяться файли tf

    - name: Apply Terraform configuration
      id: apply_terraform # додаємо ID для доступу до output
      run: terraform apply -auto-approve
      working-directory: ./terraform  # вказали директорію, де знаходяться файли tf

    - name: Get EC2 public IP
      id: get_ip  # Встановлюємо ID для отримання публічної IP
      run: |
        echo "EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)" >> $GITHUB_ENV
      working-directory: ./terraform


    - name: Set up SSH
      uses: webfactory/ssh-agent@v0.5.3
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    - name: Copy Nginx configuration
      run: |
        export EC2_PUBLIC_IP=${{ env.EC2_PUBLIC_IP }}
        envsubst < nginx.conf.template > nginx.conf
        scp -o StrictHostKeyChecking=no -i /Users/sashamelnyk/Desktop/aws/devops-practice-test-key.pem nginx.conf ec2-user@$EC2_PUBLIC_IP:/etc/nginx/conf.d/website.conf
        ssh -o StrictHostKeyChecking=no ec2-user@$EC2_PUBLIC_IP 'sudo nginx -t && sudo systemctl restart nginx'

    - name: Deploy to EC2
      run: |
        ssh -o StrictHostKeyChecking=no ec2-user@${{ env.EC2_PUBLIC_IP }} << 'EOF'
        cd /home/ec2-user/Website-ClothesShop
        git pull
        npm install

        sudo nginx -t

        sudo systemctl restart nginx

        pkill node
        nohup node app.js > output.log 2>&1 &
        EOF
```

---

## Deploy to EC2 with Docker

**Description**: application deployment on one EC2 instance with automation with Docker

1. **File settings main.tf**
   - Created S3 bucket to store state terraform configiration
   - Created smm_parameter for storage my public_ip
   - Created DynamoBD to lock the state
   ## main.tf file
```
      terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
      bucket = "application-bucket-test" # назва бакету 
      key = "terraform/terraform.tfstate" # створює файлову систему terraform де буде находитися мій файл
      region = "us-east-1" # вказуєм регіон
      dynamodb_table = "terraform-state-lock" # вказуєм таблицю для запобігання одночасного доступу
      encrypt = true # шифрування файлу 
  }

}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00f251754ac5da7f0"
  instance_type = "t2.micro"
  key_name      = "devops-practice-test-key"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id] # Прив'язка Security Group  

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "WebApplication"
  }
}

# посилаюсь на існуючу security group

data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["new_app_security_group"]  # Вкажіть ім'я вашої існуючої групи безпеки
  }
}

resource "aws_ssm_parameter" "ec2_public_ip" { 
  name  = "/my_app/ec2_public_ip" # Назва параметра
  type  = "String"
  value = aws_instance.app_server.public_ip
}
```

**As a result**: we have more is better Infrastructure as Code

### CI/CD automation details
```
name: Deploy to EC2 with Docker

on:
  push:
    branches:
      - dont-deploy

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code #  uploads code from GitHub repository.
        uses: actions/checkout@v2

      - name: Configure AWS credentials # configuration AWS to access resources (ECR, EC2)
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Install Terraform # install and initalize Terraform for managament EC2 instance.
        uses: hashicorp/setup-terraform@v1

      - name: Initialize Terraform # install and initialize Terraform for management EC2 instance.
        run: terraform init
        working-directory: ./terraform  # вказали директорію, де знаходяться файли tf

      - name: Apply Terraform configuration # Створює або оновлює EC2 інстанс за допомогою Terraform.
        id: apply_terraform # add ID to access for output
        run: terraform apply -auto-approve
        working-directory: ./terraform  # вказали директорію, де знаходяться файли tf

      - name: Get EC2 public IP
        id: get_ip  # Встановлюємо ID для отримання публічної IP
        run: | # отримуємо параметр ec2_public_ip
          EC2_PUBLIC_IP=$(aws ssm get-parameter --name "/my_app/ec2_public_ip" --query "Parameter.Value" --output text) 
          echo "EC2_PUBLIC_IP=${EC2_PUBLIC_IP}" >> $GITHUB_ENV
        working-directory: ./terraform 

      - name: Set up SSH # Встановлює SSH-з'єднання для доступу до інстансу.
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

      - name: Create directory on EC2 # Створює каталог  на EC2
        run: |
          ssh -o StrictHostKeyChecking=no ec2-user@${{ env.EC2_PUBLIC_IP }} << 'EOF'
            mkdir -p /home/ec2-user/Website-ClothesShop
          EOF

      - name: Copy Docker image and json files to EC2 # Копіює файли проекту на EC2
        run: |
          scp -o StrictHostKeyChecking=no -r ./Dockerfile ./package.json ./package-lock.json app.js ./views ec2-user@${{ env.EC2_PUBLIC_IP }}:/home/ec2-user/Website-ClothesShop/
        env:
          EC2_SSH_KEY: ${{ secrets.EC2_SSH_KEY }} # підключення через ssh для копіювання
  
      - name: Build and run Docker container on EC2 #Створює Docker-образ і запускає контейнер на EC2
        run: |
          ssh -o StrictHostKeyChecking=no ec2-user@${{ env.EC2_PUBLIC_IP }} << 'EOF'
            cd /home/ec2-user/Website-ClothesShop || exit

                                                    
            if ! command -v git &> /dev/null; then 
              sudo yum install git -y
            fi

            
            if ! command -v docker &> /dev/null; then 
              sudo amazon-linux-extras install docker -y 
              sudo service docker start      
              sudo usermod -aG docker ec2-user  # Додати користувача до групи docker 
              newgrp docker  # Застосувати зміни групи
            fi

           
            git pull

            docker build -t website-clothesshop-server .

            container_id=$(docker ps -q --filter "ancestor=website-clothesshop-server")
            if [ -n "$container_id" ]; then
                docker stop $container_id
                docker rm $container_id
            fi

            docker run -d -p 3000:3000 website-clothesshop-server
          EOF
```

## Deploy to EC2 with Docker

**Description**: application deployment on one EC2 instance with automation via Terraform
