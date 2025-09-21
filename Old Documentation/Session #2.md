# 📘 Jenkins Session #2 Documentation

---

## 🌐 HTTP Basics

### HTTP Methods

* **GET**: Request data only (read-only, no changes).
* **POST**: Send new data (e.g., sign-up to create a new user).
* **PUT**: Update existing data.
* **DELETE**: Remove data from the server.

### HTTP Status Codes

* **2xx** → Request successful.
* **3xx** → Redirection (server forwards the request to another server).
* **4xx** → Client error (e.g., `404` = requested file/path not found).
* **5xx** → Server-side error.

---

## 🐳 Running Jenkins in Docker

### Run Jenkins Container

```bash
docker run -d -p 50:8080 jenkins/jenkins:lts
```

* `-d` → Run in background.
* `-p` → Port mapping.

    * Jenkins inside container runs on **8080** by default.
    * Example above maps `localhost:50` → container `8080`.

### Useful Commands

* **List containers**

  ```bash
  docker ps
  ```

* **Enter container shell**

  ```bash
  docker exec -it <ContainerID> bash
  ```

* **Get Jenkins initial admin password**

  ```bash
  cat /var/jenkins_home/secrets/initialAdminPassword
  ```

  > Must be executed inside container.

---

## ⚙️ Jenkins Configure System Menu

* **# of executors** → Number of pipelines that can run concurrently.
* **Label** → Node label (by default this is the *master node* where Jenkins dashboard runs).
* **Usage** → Default option is fine.
* **Quiet period (default 5s)** → Delay before job starts after clicking “Build”.
* **SCM checkout retry count** → How many times Jenkins retries pulling code from GitHub before failing.
* **Jenkins URL** → Use `localhost` if no domain is configured.

---

## 🔌 Plugins and Security

* Install plugin: **Role-based Authorization Strategy**.
* After installation:

    * Go to **Manage Jenkins > Configure Global Security > Authorization**.
    * Enable **Role-Based Strategy**.

### Restart Jenkins

* Manual restart:

  ```
  http://localhost:<port>/restart
  ```

### Manage Users

* Creating a user via **Security > Manage Users** creates an **admin by default**.
* For custom roles/permissions → use **Role-based Authorization Strategy**.

### Manage & Assign Roles

* **Item role** → Restrict access to specific pipelines.
* **Node role** → Restrict access to specific nodes.
* Assign users/groups to roles under **Assign Roles**.

---

## 🔑 Credentials Management

Path: **Manage Jenkins > Credentials > Stores Scoped to Jenkins > System > Global credentials**

* Use to securely store:

    * GitHub tokens
    * DockerHub credentials
    * SSH keys
    * Slack tokens

⚠️ Avoid writing credentials in pipelines directly — they will be visible in GitHub if code is pushed.
Stored credentials:

* Can be **referenced by ID** inside pipelines.

* Cannot be revealed — only updated.

* **GitHub Authentication**:

    * Use **Personal Access Token** (created in GitHub Developer Settings).

* **SSH**: Provides secure, encrypted remote access and authentication.

---

## 🛠️ Tools & Actions

* **Script Console**: Run Groovy scripts on the Jenkins server (not inside pipelines).
* **Prepare for Shutdown**: Gracefully stop Jenkins server.
* **Jenkins Home Directory**:

  ```
  /var/jenkins_home/
  ```

  Stores all jobs, builds, and configurations inside the container.

---

## ➕ Creating Jobs (New Item Menu)

Options:

1. **Freestyle**
2. **Pipeline**
3. **Multibranch Pipeline**

---

### 📝 Freestyle Job

#### General Menu

* **Discard old builds** → Limit builds saved to save disk space.
* **Days to keep builds** / **Max # of builds to keep** → Set retention policy.
* **This project is parametrized** → Add parameters (e.g., Choice parameter) to conditionally execute builds.
* **Throttle builds** → Limit frequency of builds.
* **Disable project** → Keep config but disable execution.
* **Execute concurrent builds** → Allow multiple builds in parallel.

#### Source Code Management

* Connect to GitHub via **Git**.
* Add repo URL + credentials (if private).

#### Build Triggers

* **Manual (default)** → Trigger via Build button.
* **Trigger builds remotely** → Trigger via API/token.
* **Build after other projects** → Run after another project completes.
* **Build periodically** → Cron-like schedule.
* **GitHub hook trigger for GITScm polling** → Auto-build on GitHub events (push, PR).

    * Requires Jenkins to be publicly accessible (e.g., via AWS EC2).
* **Poll SCM** → Poll GitHub repo periodically; only build if changes detected.

#### Build Environment

* **Delete workspace before build** → Clean workspace before new build.
* **Abort build if stuck** → Timeout mechanism.
* **Add timestamps to console output** → Shows time per log line.

#### Build Step

* Example with **Execute shell**:

  ```bash
  ls
  mkdir test
  cd test
  touch file1
  ```

#### Post-Build Actions

* Build another project.
* Send Slack notification.
* Commit changes to GitHub.
* Delete workspace.

#### Workspace

* Each project has a dedicated folder under:

  ```
  /var/jenkins_home/workspace/<project_name>
  ```

---

## ⚠️ Notes on Accuracy

* “In **Manage Users**, any new user is considered admin.” → **(AI: not accurate)**

    * By default, Jenkins creates the first user as admin. Subsequent users **can** be restricted if Role-based Authorization Strategy is enabled.

* “GitHub hook trigger requires AWS EC2 with public ID.” → **(AI: partially inaccurate)**

    * Jenkins just needs to be publicly accessible (not necessarily AWS). Could also use Ngrok, a reverse proxy, or any hosting solution.

---


## 📝 General Menu (Pipeline Job)

* **Don’t allow the pipeline to resume if controller restarts**

    * Prevents pipelines from resuming automatically after Jenkins restarts.

* **Pipeline speed/durability override**

    * Trade-off between **speed** and **durability**:

        * **Speed** → Jenkins does not checkpoint frequently. If server crashes, progress is lost.
        * **Durability** → Jenkins checkpoints (saves) pipeline state periodically. Jobs can resume after a crash, but with more overhead.
    * **Default** option is usually recommended.

---

## 🛠️ Pipeline Menu (VIP)

Two ways to define pipelines:

1. **Pipeline script**

    * Write a Groovy script directly in Jenkins UI.
    * Less maintainable (stored inside Jenkins server).

2. **Pipeline script from SCM (recommended)**

    * Store pipeline as code (`Jenkinsfile`) in a Git repo.
    * Advantages:

        * Preserves configuration even if Jenkins server is destroyed.
        * Full version control history of pipeline evolution.
        * Treats pipeline like regular code (review, improve, share).
    * **Default Jenkinsfile name**: `Jenkinsfile`.

---

## 🔧 Pipeline Syntax Styles

### 1) Scripted Pipeline

* Older syntax, fully Groovy-based.
* Example:

```groovy
node {
    stage('Preparation') {
        // Pull code
        git 'https://github.com/jglick/simple-maven-project-with-tests.git'
        // Use Maven tool configured globally as "M3"
        mvnHome = tool 'M3'
    }

    stage('Build') {
        withEnv(["MVN_HOME=$mvnHome"]) {
            if (isUnix()) {
                sh '"$MVN_HOME/bin/mvn" -Dmaven.test.failure.ignore clean package'
            } else {
                bat(/"%MVN_HOME%\bin\mvn" -Dmaven.test.failure.ignore clean package/)
            }
        }
    }

    stage('Results') {
        junit '**/target/surefire-reports/TEST-*.xml'
        archiveArtifacts 'target/*.jar'
    }
}
```

---

### 2) Declarative Pipeline

* Modern, widely adopted.
* Structured and easier to read.
* Syntax:

  ```
  pipeline > stages > stage(s) > steps
  ```

#### Example 1: Simple "Hello World"

```groovy
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```

#### Example 2: Using Maven

```groovy
pipeline {
    agent any

    tools {
        maven "M3"   // Install Maven (configured in Global Tool Configuration)
    }

    stages {
        stage('Build') {
            steps {
                // Pull code
                git 'https://github.com/jglick/simple-maven-project-with-tests.git'

                // Run Maven
                sh "mvn -Dmaven.test.failure.ignore=true clean package"

                // Multiple commands in one step
                sh """
                    ls
                    mkdir test1
                """
                // For Windows agents use:
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }
            post {
                success {
                    // Archive test results and build artifacts
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
                failure {
                    // Add failure handling logic here
                }
            }
        }
    }
}
```

---

## 📊 Pipeline Status

* **Success** → Pipeline ran successfully.
* **Unstable** → Some tests failed but build artifacts still created.
* **Failure** → Pipeline failed due to errors (e.g., syntax issues, directory already exists).

---

## ⚠️ Notes on Accuracy

* Transcript says:

  > “Failed: Syntax error for example: create a Dir. which already exists”

    * **(AI: not accurate)** → “Failure” means **pipeline execution failed** due to an error (could be syntax, missing tools, runtime error, etc.). Creating a directory that already exists would cause a failure **only if the script is not written defensively**.

---

# 📘 Jenkins Exercise — CI/CD for Node.js Docker App

---

## 🎯 Goal

* Use Jenkins to:

    1. Build a **Node.js Docker image** from a `Dockerfile`.
    2. Push that image to **Docker Hub**.
    3. Deploy a container from the image locally on Jenkins server.

👉 Flow:

```
Dockerfile → Docker Image → Docker Container
                |
                v
            Push to DockerHub
```

---

## 📝 Jenkinsfile Solution

```groovy
pipeline {
    agent any
    stages {
        stage('CI') {
            steps {
                // Make sure you created Docker Hub credentials in Jenkins first
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh """
                    # Build Docker image
                    docker build . -f dockerfile -t ahmedarafat10/jenkins_nodejs:latest

                    # Login to Docker Hub
                    docker login -u ${USERNAME} -p ${PASSWORD}

                    # Push Docker image to Docker Hub
                    docker push ahmedarafat10/jenkins_nodejs:latest
                    """
                }
            }
        }

        stage('CD') {
            steps {
                sh """
                # Run Docker container from pushed image
                docker run -d -p 3000:3000 ahmedarafat10/jenkins_nodejs:latest
                """
            }
        }
    }
}
```

### Notes

* `sh """ ... """` → use **triple quotes** for multiline commands.
* `sh "..."` → use **double quotes** for a single command.

---

## ⚠️ Problem: Docker Inside Jenkins Container

If Jenkins is running inside a Docker container:

* Trying to execute `docker` commands will fail with:

  ```
  docker: command not found
  ```
* Reason: Jenkins image does **not** include Docker CLI.
* Also, even if CLI is installed, the container must access the **Docker daemon** running on host.

---

## 🛠️ Solution: Jenkins with Docker CLI

1. **Build a custom Jenkins image with Docker CLI installed**
   Create `jenkins_docker` Dockerfile:

   ```dockerfile
   FROM jenkins/jenkins:lts

   USER root
   RUN apt-get update && apt-get install -y docker.io \
       && usermod -aG docker jenkins

   USER jenkins
   ```

   Build the image:

   ```bash
   docker build . -f jenkins_docker -t ahmedaraft10/jenkins_docker:latest
   ```

2. **Run Jenkins with Docker socket mounted**

   ```bash
   docker run -d -p 9090:8080 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      ahmedaraft10/jenkins_docker:latest
   ```

    * `-v /var/run/docker.sock:/var/run/docker.sock` → shares Docker daemon from host to container.
    * Jenkins user must belong to `docker` group.

3. **Configure new Jenkins server**

    * Add **Docker Hub credentials** in Jenkins > Manage Credentials.
    * Create a new pipeline → select **Pipeline script from SCM**.
    * Link to GitHub repo containing:

        * Your `Dockerfile`
        * Your `Jenkinsfile`

4. **Pipeline will execute**:

    * CI:

        * Build Node.js image from Dockerfile.
        * Login to DockerHub.
        * Push image.
    * CD:

        * Run a new container from the image on Jenkins server.

---

## ✅ Test Deployment

After pipeline finishes:

* Access Node.js app in browser:

  ```
  http://localhost:3000
  ```

⚠️ Transcript says **localhost:3030** → **(AI: not accurate)**

* The Jenkinsfile uses port `3000:3000`, so app should be available at **[http://localhost:3000](http://localhost:3000)**.
* If you want `3030`, you need to map differently:

  ```bash
  docker run -d -p 3030:3000 ahmedarafat10/jenkins_nodejs:latest
  ```

---

## 🔑 Key Takeaways

* Jenkins default container **cannot run Docker commands**.
* Solution: build a **custom Jenkins image with Docker CLI** and map Docker socket.
* Store pipeline (`Jenkinsfile`) in GitHub to make it reproducible.
* CI/CD flow = **Build → Push → Deploy**.


````
VVVIP Note: The problem in above script is that it runs a {$ docker command} which is not found
inside Jenkins Docker Containers {Erros is -> docker: is not found error, as you are trying to
run $docker command in side a docker container {after entering inside jenkins container ($ docker exec)} }
you cannot run $docker command inside it as docker is not installed on it, we run it in host
pc as its installed on it,so we have to make jenkins server can run $ docker commands as well


-> Docker is consists of two main componants {docker client & docker deamon}
we want to install docker clinet CLI inside jenkins docked container
then make docker client run command send it to docker daemon which exist in host pc

-> We will create a dockerfile {which will be built to create an image of modified Jenkins}.
-> Inside dockerfile: From Jenkins image we will build another modified image, install
docker clinet inside it and then add user {jenkins} in group {docker} as jenkins server run every
thing using user called jenkins then create an image from that dockerfile {docker file is called Jenkins_Docker}
$ docker build . -f jenkins_docker -t ahmedaraft10/jenkins_docker:latest

//Then create a NEW Jenkins Docker Container of modified Jenkins image and mapped it to docker daemon path
$ docker run -d -p 9090:8080 -v /var/run/docker.sock:/var/run/docker.sock ahmedaraft10/jenkins_docker:latest

-> Then after configiring new Jenkins Server {that can run docker client CLI} create a new
pipline then pipeline uses option {script from SCM} then add github repo {add Docker Hub Account
in credential menu if you are going to pull image to your dockerhub acc}

-> Then choose Jenkinsfile that contains groovy script to automate CI/CD which will execute:
    -> Create image of nodejs from dockerfile
    -> Login to your dockerhub account
    -> Pull created image to your account
    this is CI, while CD is:
    -> Create a container that runs nodejs image and port it to host container

-> Now save new pipeline configurations and then build it then wait until build is done then
   in chrome enter {localhost:3030} and now nodejs Website will work
````