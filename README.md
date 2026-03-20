<div align="center">
  <img src="https://www.jenkins.io/images/logos/jenkins/jenkins.svg" alt="Jenkins Logo" width="150"/>

<h1>Jenkins CI/CD Documentation</h1>

</div>


This repository documents a complete hands-on journey through **Jenkins**, covering **Continuous Integration (CI)**, *
*Continuous Deployment (CD)**, **Docker**, and **AWS (S3, EC2, ECS)**.

- [Terminologies](./Terminologies.md)

The content is structured into sections, each representing a key stage in building production-ready CI/CD pipelines.



---

## 📦 Section 01 – Introduction to Jenkins

- Jenkins installation and initial setup
- Installing plugins (e.g., Stage View)
- Creating and running your first Jenkins job
- Jenkins history and evolution
- Jenkins architecture (Controller & Agents)
- Creating your first Jenkins Pipeline
- Jenkins workspace concept
- Managing and storing build artifacts
- Debugging pipeline failures
- Understanding shell commands in pipelines
- Combining multiple shell steps
- Pipeline stages and structuring workflows
- Exit codes and failure handling
- Testing build artifacts
- Using environment variables in pipelines
- Visualizing pipelines (Graph View)
- Introduction to DevOps concepts

---

## 🔄 Section 02 – Continuous Integration (CI) with Jenkins

- Introduction to Continuous Integration (CI)
- Overview of a sample web project
- Using Docker as a build environment
- Workspace synchronization in Jenkins
- Integrating Git repositories (SCM)
- Building applications inside Jenkins
- Jenkins + Docker architecture (behind the scenes)
- Running automated tests
- Publishing JUnit test reports
- Writing maintainable pipelines with comments
- Running End-to-End (E2E) tests using Playwright
- Generating HTML test reports
- Handling common CI challenges and fixes
- Understanding key CI concepts and best practices

---

## 🚀 Section 03 – Continuous Deployment (CD) with Jenkins

- Manual deployment strategies
- Installing and using CLI tools
- Managing configuration via environment variables
- Handling secrets securely in Jenkins
- Using Jenkins credentials in pipelines
- Deploying applications to production
- Build triggers:
    - Scheduled builds
    - SCM polling (Git-based triggers)
- Post-deployment testing
- Staging environments and deployment strategies
- Deploying to staging before production
- Manual approval steps in pipelines
- Passing dynamic data between stages
- Parsing API responses inside pipelines
- Combining and optimizing pipeline stages
- Continuous Delivery vs Continuous Deployment
- Versioning builds
- Using `curl` for application validation

---

## 🐳 Section 04 – Docker for DevOps

- Building Docker images
- Using custom Docker images in Jenkins pipelines
- Running scheduled (nightly) Docker builds
- Installing Linux packages inside Docker agents
- Writing Dockerfiles for custom environments

---

## ☁️ Section 05 – Deployment to AWS (S3 & EC2)

- Introduction to Cloud Computing
- AWS fundamentals and core services
- Amazon S3 for file storage
- AWS CLI setup and usage
- AWS CLI v1 vs v2 differences
- Managing AWS services via CLI
- Identity and Access Management (IAM)
- Managing AWS credentials in Jenkins
- Uploading files to S3
- Hosting static websites on S3
- Syncing files to S3 using AWS CLI
- Introduction to Amazon EC2 (virtual servers)

---

## 🐳☁️ Section 06 – Deployment to AWS ECS (Docker-Based)

- Introduction to Amazon ECS
- ECS infrastructure and launch modes
- Creating ECS clusters
- Defining ECS task definitions
- Running and managing ECS services
- Updating task definitions via AWS CLI
- Updating ECS services programmatically
- Passing data between AWS CLI commands
- Using AWS CLI `wait` command
- Requirements for deploying applications to ECS
- Building Docker images for ECS deployment
- Creating custom AWS CLI Docker images
- Tagging Docker images properly
- Amazon ECR (Docker registry)
- Referencing ECR images in ECS task definitions
- Using Linux tools like `sed` for automation

---

## 🧠 Section 07 – Final Thoughts

- Jenkins ecosystem evolution
- Future of CI/CD and automation tools
- Best practices and learning roadmap
