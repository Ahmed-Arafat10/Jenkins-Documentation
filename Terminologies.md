## 📘 Terminologies

### Jenkins Concepts

* **Jenkins Jobs**: Tasks that Jenkins executes to automate processes like build, test, and deployment.

    * **Freestyle Job**: Simple job configured via UI with limited flexibility.
    * **Pipeline Job**: Script-based job (using a Jenkinsfile) that supports complex workflows and multiple stages.

* **Jenkins Controller (Master)**: The main Jenkins server responsible for managing jobs, configurations, and agents.

* **Jenkins Agent (Node)**: A machine that executes jobs assigned by the controller.

* **Jenkins Workspace**: The directory on an agent where source code is checked out and builds are executed.

* **Pipeline as Code (Jenkinsfile)**: Defining CI/CD pipelines using code (Groovy-based script stored in SCM).

* **Groovy Pipeline Script**: The scripting language used to define Jenkins pipelines.

* **Jenkins Script Block**: A block (`script {}`) in pipeline used for writing custom Groovy logic.

* **Shell Execution Context**: The environment in which shell commands (`sh`) are executed inside pipelines.

* **Parallel Block**: Allows multiple stages or steps to run concurrently.

* **Wrapper Stage**: A stage that wraps other stages to apply shared logic (e.g., environment setup).

* **Jenkins Replay Button**: Feature that allows rerunning a pipeline with modified script (without changing source).

* **Jenkins Input Step**: Pauses pipeline execution and waits for manual user input.

* **Jenkins Timeout Step**: Stops execution if a step exceeds a defined time limit.

* **Build Triggers**: Mechanisms to start builds automatically.

    * **Build Periodically**: Runs jobs on a schedule (cron).
    * **Poll SCM**: Checks source control for changes and triggers builds.

* **Jenkins Environment Variables (`env`)**: Built-in variables like `JOB_NAME`, `BUILD_ID`, `BUILD_NUMBER`.

---

### Source Control & Pipeline

* **SCM (Source Control Management)**: Systems like Git used to manage code versions.

* **Workspace Synchronisation**: Ensuring workspace reflects the latest source code from SCM.

---

### Docker & Execution

* **Docker-in-Docker (DinD)**: Running Docker inside a Docker container.

* **node-jq**: A Node.js wrapper around `jq` for processing JSON data.

---

### Testing & Reporting

* **JUnit Test Report**: Standard format for publishing test results in Jenkins.

* **End-to-End (E2E) Tests**: Tests that validate the complete application flow.

* **Playwright**: Automation framework for browser testing.

---

### Security & Config

* **Credentials Binding**: Securely injecting secrets (API keys, passwords) into pipelines.

* **Jenkins Credentials**: Stored secrets used by Jenkins jobs securely.

* **withCredentials**: Pipeline step to access credentials securely in scripts.

* **Content Security Policy (CSP) Header**: Security layer to prevent XSS and data injection attacks.

---

### Artifacts & Deployment

* **Artifact**: Output of a build process (e.g., compiled app, Docker image).

* **Netlify**: Platform for deploying frontend applications.

    * **Site ID**: Unique identifier for a Netlify site.
    * **Netlify Access Token**: Token used for authentication with Netlify API.

---

### AWS Services

* **AWS S3 (Simple Storage Service)**: Object storage service for storing files.

    * **Buckets**: Containers for storing objects.
    * **Objects**: Files stored in buckets.

* **AWS IAM (Identity and Access Management)**: Manages users, roles, and permissions.

* **AWS ECS (Elastic Container Service)**: Container orchestration service.

    * **Cluster**: Group of compute resources.
    * **Task Definition**: Blueprint for running containers.
    * **Service**: Maintains desired number of running tasks.
    * **Revision**: Version of a task definition.

* **AWS ECR (Elastic Container Registry)**: Docker image registry.

* **AWS CLI**: Command-line tool for interacting with AWS services.

* **Principle of Least Privilege**: Granting only necessary permissions to reduce security risks.

---

### Integrations

* **Slack with Jenkins**: Integration to send build notifications to Slack channels.

---

### Plugins

* **Stage View Plugin**: Visualizes pipeline stages.

* **Docker Pipeline Plugin**: Enables Docker usage inside Jenkins pipelines.

* **HTML Publisher Plugin**: Publishes HTML reports in Jenkins.

* **Slack Notification Plugin**: Sends Jenkins notifications to Slack.