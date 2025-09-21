# 📘 Jenkins Documentation – Session #3

## 1. Multi-Branch Pipeline

* A **multi-branch pipeline** allows Jenkins to automatically detect and create pipelines for each branch in a GitHub repository.
* It works the same as a single pipeline job, but instead of manually configuring multiple jobs, Jenkins:

    * Scans the repo.
    * Finds every branch that contains a `Jenkinsfile`.
    * Creates an independent pipeline for each branch.
* **Benefit**: More efficient when managing multiple branches and pipelines.

---

## 2. Git-Flow Architecture

A typical Git branching model includes the following branches:

* **Feature Branch**
* **Develop Branch**
* **Release Branch**
* **Testing Branch**
* **Production Branch**
* **Master Branch**
* **Hotfix Branch**

📌 **Note**:
In many modern workflows, the **`main` branch** often replaces **`master`**. Also, not all teams use this exact model; some simplify it.

---

## 3. Master & Node Architecture

* By default, Jenkins has a **Master node** (where the Jenkins dashboard runs and jobs can execute).
* It is recommended to:

    * Keep the **Master node** only for dashboard and orchestration.
    * Run **build pipelines on Slave/Agent nodes** (dedicated servers).
* Benefit: Workload separation → if a pipeline crashes, it doesn’t impact the Jenkins master.

---

## 4. Setting Up Slave Nodes

We will configure **two types of slave nodes**:

1. AWS EC2 (Ubuntu)
2. Docker Container (Ubuntu image)

---

### 4.1 AWS EC2 Slave Node

#### Steps:

1. **Create an EC2 instance**:

    * Choose Ubuntu (default config is fine).
    * Download the **Key Pair** file (`.pem`).

2. **Prepare SSH key**:

   ```bash
   cp ~/Downloads/key_pair_name.pem <new_path>
   chmod 400 key_pair_name.pem
   ```

3. **SSH into EC2**:

   ```bash
   ssh -i key_pair_name.pem ubuntu@<IPv4_Address>
   ```

    * `ubuntu` is the default username for Ubuntu EC2 AMIs.

4. **Install Java (required by Jenkins agent)**:

   ```bash
   sudo apt update
   sudo apt-get install openjdk-8-jdk -y
   ```

   ⚠️ **(AI: not accurate)** → OpenJDK 8 is not always required.

    * Jenkins agents typically work with newer versions (e.g., OpenJDK 11).
    * It depends on Jenkins master version and pipeline tools.

5. **Create a workspace directory**:

   ```bash
   mkdir ~/Jenkins
   ```

---

### 4.2 Configure AWS Node in Jenkins Dashboard

1. Go to **Dashboard → Manage Nodes and Clouds → New Node**.

2. Create a **Permanent Agent**.

3. Configure:

    * **Remote root directory** → `/home/ubuntu/Jenkins`
      (the workspace we created inside EC2).
    * **Labels** → e.g., `AWS`.
    * **Launch method** → Launch agent via SSH.

4. **SSH Credentials**:

    * Add credential → type: `SSH Username with private key`.
    * Username: `ubuntu`.
    * ID: e.g., `SSH-AWS-Slave`.
    * Private Key: copy entire contents of `key_pair_name.pem`.

5. **Host Key Verification Strategy** → Non-verifying.

---

### 4.3 Run Pipeline on AWS Node

* Create a **new pipeline job**.
* Use GitHub repo (with Maven project as example).
* In pipeline script, change:

  ```groovy
  agent { label "SSH-AWS-Slave" }
  ```
* Ensure Maven is configured in **Global Tool Configuration**:

    * Add Maven installation (e.g., name it `M3`).
    * Pipeline script can then call `M3`.

---

## 5. Advantages of Using Slave Nodes

* Workload is distributed across multiple servers.
* If a **pipeline crashes or consumes resources heavily**, only the slave node is affected.
* Jenkins master remains responsive.


## Continue: Jenkins Session #3 — Configure a Docker Container as a Jenkins Agent (Slave)

---

## Goal

Make an Ubuntu Docker container act as a Jenkins agent (so Jenkins master can run builds on it via SSH).

---

## Summary of the approach

1. Run an Ubuntu container.
2. Install OpenJDK (agent needs Java) and OpenSSH server inside the container.
3. Create a workspace directory for Jenkins.
4. Generate / place an SSH public key in the container's `~/.ssh/authorized_keys`.
5. Add the private key to Jenkins as an **SSH Username with private key** credential.
6. Add a new Jenkins node using the container’s IP, SSH credential, and “Launch agent via SSH”.
7. Use the node label in your `Jenkinsfile` to run jobs on that agent.

---

## Step-by-step commands (as in transcript)

### 1) Start an Ubuntu container interactively

```bash
docker run -it ubuntu bash
```

### 2) Inside the Ubuntu container — update & install Java

```bash
sudo apt update
sudo apt-get install -y openjdk-8-jdk
```

* Create workspace dir:

```bash
mkdir ~/Jenkins
```

> (AI: not accurate) — *OpenJDK 8 requirement.*
>
> * **Why:** Jenkins agents generally require a Java runtime, but the exact Java version depends on Jenkins master and plugins. Many setups use OpenJDK 11 or newer. OpenJDK 8 may still work but is not universally required. Choose the Java version that matches your Jenkins master compatibility.

### 3) Install and start OpenSSH server (inside container)

```bash
apt install -y openssh-server
service ssh start
```

> (AI: not accurate) — *`service ssh start` in plain Docker ubuntu image may not work as expected.*
>
> * **Why:** Official Ubuntu images do not run `systemd` by default inside containers; `service` may exist but the sshd may not run the same way as a VM. A reliable command to start the server is often:

```bash
mkdir -p /var/run/sshd
/usr/sbin/sshd -D &
```

> * Alternative: build a Docker image that installs and configures `openssh-server`, exposes port 22, and starts sshd in foreground. Or run container with an init system or supervisord.

### 4) Generate SSH key pair (transcript shows generating keys inside the container)

```bash
ssh-keygen
cd ~/.ssh
ls   # shows id_rsa  id_rsa.pub
cat id_rsa        # private key
cat id_rsa.pub    # public key
```

* Copy **private key** (id\_rsa) contents for Jenkins credentials.
* Copy **public key** (id\_rsa.pub) into `~/.ssh/authorized_keys` on the container:

```bash
vi ~/.ssh/authorized_keys
# paste public key (without the "user@host" suffix if desired), save
chmod 600 ~/.ssh/authorized_keys
```

> (AI: not accurate) — *Generating SSH keys on the container and then copying the private key into Jenkins is functional but not a best practice.*
>
> * **Why:** Best practice is to generate the key pair **on the Jenkins master (or admin machine)** and **only copy the public key** into the agent's `authorized_keys`. The private key should remain private and stored in Jenkins credentials (which is okay) — generating on master ensures the private key didn't originate on the agent. If you generated on container, you must securely transfer the private key to Jenkins; that works but is less ideal for key lifecycle and trust.

### 5) Ensure `authorized_keys` contains the public key (transcript example public key shown)

* Example `authorized_keys` entry (single long `ssh-rsa ...` line). Ensure no trailing host comment if you prefer.

### 6) Add SSH credential in Jenkins (Manage Jenkins → Credentials)

* Type: **SSH Username with private key**

    * ID: e.g., `container-slave-SSH`
    * Username: `root` (or whichever user you will SSH as)
    * Private Key: paste the private key text (begins `-----BEGIN RSA PRIVATE KEY-----` or similar)

> (AI: note) — If you generated keys on the Jenkins host, paste private key here. If you generated inside the container, ensure private key text is transferred securely.

### 7) Identify container IP address (on host)

* List containers:

```bash
docker ps
```

* Inspect container to get IP:

```bash
docker inspect <container_id>
# look for .NetworkSettings.IPAddress or network section
```

* Use that IP as the **Host** when creating the new node.

> (AI: not accurate) — *Container IP accessibility caveat.*
>
> * **Why:** Container IP is reachable from the Docker host but may not be reachable from other machines depending on Docker network configuration (bridge). If Jenkins master runs on the same host, it can usually reach the container IP. If Jenkins master is remote, you must ensure network routing or use `-p` to publish port 22 to the host (e.g., `-p 2222:22`) and use host IP + mapped port. Using container IP works in many single-host setups but is not universally accessible.

### 8) Add new node in Jenkins

* Jenkins → **Manage Jenkins** → **Manage Nodes and Clouds** → **New Node**

    * Name: `docker` (or other)
    * Type: **Permanent Agent**
    * Remote root directory: `/root/Jenkins` (or `/home/ubuntu/Jenkins` depending on user)
    * Labels: `docker`
    * Launch method: **Launch agent via SSH**
    * Host: (container IP)
    * Credentials: select earlier SSH credential (`container-slave-SSH`)
    * Host Key Verification Strategy: **Non verifying verification strategy**
    * Save / Launch

> (AI: not accurate) — *Using "Non verifying verification strategy" is insecure.*
>
> * **Why:** It skips host key verification and opens you to man-in-the-middle attacks. For production, prefer to store the agent host key in Jenkins or use `Known hosts` verification strategy.

### 9) Ensure Git is installed inside the container

* If your pipeline `Jenkinsfile` uses `git` step (common), install git inside the container:

```bash
apt-get install -y git
```

> Transcript note: *“NOTE: install Git inside Ubuntu container as git command is used in groovy script to prevent happening of an error”* — correct.

### 10) Change pipeline `agent` label to run on the container

In your pipeline script (Jenkinsfile):

```groovy
agent { label "docker" }   // matches label you set on the node
```

Also ensure **Global Tool Configuration** has the needed tools (Maven `M3`, JDK, etc.) configured if your build uses them.

---

## Additional practical tips & gotchas

* **Port publishing alternative**: Instead of using container IP, run the container mapping SSH to a host port:

  ```bash
  docker run -d -p 2222:22 ubuntu
  ```

  Then use host IP + port 2222 in Jenkins node config.

* **sshd in container**: To run sshd reliably in a container, it's often better to create a Dockerfile that installs `openssh-server`, configures `/etc/ssh/sshd_config`, exposes port 22, and starts `sshd` in foreground. Example minimal Dockerfile:

  ```dockerfile
  FROM ubuntu:22.04
  RUN apt-get update && apt-get install -y openssh-server openjdk-11-jdk git
  RUN mkdir /var/run/sshd
  RUN echo 'root:root' | chpasswd   # for quick testing only (not recommended)
  EXPOSE 22
  CMD ["/usr/sbin/sshd","-D"]
  ```

  Then `docker build -t jenkins-ubuntu-agent .` and `docker run -d -p 2222:22 jenkins-ubuntu-agent`.

* **User choice**: The transcript uses `root` as SSH user. For security, prefer a non-root user (e.g., `jenkins`) with proper permissions.

* **Java version**: Make sure installed Java on agent is compatible with Jenkins master. OpenJDK 11 is a safe default for recent Jenkins versions.

* **Firewall / connectivity**: Ensure host/VM firewalls allow SSH ports.

* **Agent startup method**: SSH launch method causes the master to SSH to the agent and start the agent Java process (`agent.jar`). To use this, the agent must have Java installed and `sshd` running.

---

## (AI: not accurate) flags summary (transcript points that needed clarification)

1. **`service ssh start` in plain Docker image** — may not start as expected because systemd/service management may be absent. Use `/usr/sbin/sshd -D &` or build an image that starts sshd in foreground.
2. **Generating keys inside container then adding private key to Jenkins** — works but is not best practice; better to generate keys on the Jenkins host and add the public key to agent.
3. **Using container IP directly** — works for same-host master but can fail when master is remote or network is restrictive; publishing port is often more reliable.
4. **Host Key Verification Strategy = Non verifying** — insecure for production. Use known hosts or Jenkins-managed known hosts.
5. **OpenJDK 8 required** — not always; use Java version compatible with your Jenkins version (OpenJDK 11 is common).

---

## Final checklist before running pipeline on the Docker slave

* [ ] Container has Java installed (`java -version`).
* [ ] `openssh-server` installed and `sshd` running.
* [ ] Your SSH public key is in `~/.ssh/authorized_keys` of the SSH user.
* [ ] Jenkins has a matching SSH credential with the private key.
* [ ] Node added in Jenkins with proper label and reachable host/port.
* [ ] Git (and other build tools) installed inside the container if pipelines require them.
* [ ] Global Tool Configuration in Jenkins has required tools (Maven, JDK names) if used in `Jenkinsfile`.


### Extra

### Q: but $ ssh-keygen is executed in container so why i the public key of that container is taken in authorized_keys

Great catch 👌 — this is the exact confusion point. Let’s slow it down.

---

### What happens when you run `ssh-keygen` **inside the container**

* You are generating a keypair **owned by the container** (the would-be agent).
* That produces:

    * `id_rsa` → private key (inside container)
    * `id_rsa.pub` → public key (inside container)

Then in the transcript:

* You copied the **container’s private key** into Jenkins master’s credentials.
* You copied the **container’s public key** into the container’s `~/.ssh/authorized_keys`.

⚠️ That works, but it’s **not how SSH trust is designed**.
Why?

* In SSH, the **client (Jenkins master)** must have the private key.
* The **server (agent container)** only needs the public key.
* If you generate the keys inside the container and then move the private key out → you’ve reversed the ownership model.

That’s why I marked earlier:

> Better practice → generate the key on Jenkins master (client), then copy the **public key** into the container’s `authorized_keys`.

---

### Why `authorized_keys` needs the **public key**

The file `~/.ssh/authorized_keys` is where an SSH server (the agent container) looks to verify:

* “Does the connecting client (Jenkins master) have the private key matching one of these public keys?”
* If yes → connection allowed.
* If no → rejected.

So, even if you generated the keypair in the wrong place (inside the container), you still had to put the **public key into `authorized_keys`**. Otherwise, SSH wouldn’t know to trust the private key presented by Jenkins.

---

✅ Correct flow should be:

1. Run `ssh-keygen` on Jenkins master.
2. Add **private key** to Jenkins credentials.
3. Copy the **public key** into agent container’s `~/.ssh/authorized_keys`.

````
---------------------------------------------
TASK: create an Ubuntu slave docker container
---------------------------------------------
but this time from dockerfile to automate everything {in dockerfile make new Dir./
install openjdk / install ssh /generate keys / add public key to authorized_keys etc...}
+ installing a docker CLI in it {add statements of dockerfile that install docker
client on container from previous session}
so Jenkinsfile can run docker commands inside ubuntu container
do not forget to Edit ---> agent {label "Slave_Name"} in Jenkinsfile


-> So this is to have a dockerfile then build it to create an image then just take
its IPaddress and put it in nodes configurations in Jenkins Server {other steps are all automated}



-> Then create a script to :
1) Copy file that contains private key from docker container to my host to use it in jenkins
$ docker cp <ContainerID>:~/.ssh/id_rsa /home/arafat/Desktop/jenkinsproject
2- to copy ipaddress of container
$ docker inspect <ContainerID> > IPAddress

script.sh file :
docker cp $1:~/.ssh/id_rsa /home/arafat/Desktop/jenkinsproject
docker inspect $1 > IPAddress

In terminal :
source script.sh <Container_ID>


When you ssh a server $ ssh -i sprint.pem ubuntu@IPAddress then a message will pop up in terminal then you typed yes
there is a file created in ~/.ssh called known_hosts thet contains all server you have connected to , which means that you have trusted this server
next time you ssh on this server no message will be shown
this is meaning of {Host key verification strategy -> Non verifying verification strategy } option
(as I entered yes for that message)
````

Perfect — you’re trying to **fully automate your Jenkins Docker slave build** with a `Dockerfile` + script.
I’ll give you a clean and corrected setup, and also point out best practices.

---

## ✅ 1) Dockerfile (Ubuntu Jenkins Agent with SSH + OpenJDK + Docker CLI)

Here’s a production-style Dockerfile that prepares the container:

```dockerfile
FROM ubuntu:20.04

# Non-interactive to avoid tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenJDK, SSH server, Docker CLI, Git, and other basics
RUN apt-get update && \
    apt-get install -y \
        openjdk-11-jdk \
        openssh-server \
        git \
        curl \
        ca-certificates \
        gnupg \
        lsb-release \
        vim && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CLI (not daemon, just client binary)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN mkdir /var/run/sshd

# Create Jenkins workspace dir
RUN mkdir -p /root/Jenkins

# Generate SSH keys (private + public) for this container
RUN ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys

# Expose SSH port
EXPOSE 22

# Start SSH service on container run
CMD ["/usr/sbin/sshd", "-D"]
```

---

## ✅ 2) Build and run the image

```bash
# Build the image
docker build -t jenkins-ubuntu-slave .

# Run the container (detached mode)
docker run -d --name ubuntu-slave jenkins-ubuntu-slave
```

---

## ✅ 3) Script to extract private key + container IP

`script.sh`:

```bash
#!/bin/bash
CONTAINER_ID=$1

# Copy private key from container to host
docker cp $CONTAINER_ID:/root/.ssh/id_rsa /home/arafat/Desktop/jenkinsproject

# Extract container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID > IPAddress

echo "Private key copied to /home/arafat/Desktop/jenkinsproject"
echo "Container IP saved to IPAddress"
```

Usage:

```bash
chmod +x script.sh
./script.sh ubuntu-slave
```

---

## ✅ 4) Jenkins Configuration

* Add new **node** in Jenkins (`Manage Nodes and Clouds → New Node`)

* Node name: `docker-slave`

* Remote root dir: `/root/Jenkins`

* Labels: `docker-slave`

* Launch method: **Launch agent via SSH**

    * Host: (use IP from `IPAddress` file)
    * Credentials: Add `SSH username with private key` →

        * Username: `root`
        * Private key: paste from `/home/arafat/Desktop/jenkinsproject/id_rsa`

* Host key verification strategy: `Non verifying verification strategy`
  → Equivalent of answering “yes” the first time.

---

## ✅ 5) Jenkinsfile update

When you define a pipeline, replace `agent any` with:

```groovy
pipeline {
    agent { label 'docker-slave' }

    stages {
        stage('Build') {
            steps {
                sh 'java -version'
                sh 'docker --version'
                sh 'git --version'
            }
        }
    }
}
```

---

⚠️ **Best Practice Reminder**:
It’s better to **generate the keypair on Jenkins master**, and only place the **public key** inside the container.
Right now, you’re generating the private key inside the container and exporting it out → works but isn’t ideal for security.


Got it 👍 Let me turn this into structured documentation while also highlighting clarifications and best-practice notes.

---

# 🔔 Jenkins Integration with Notification & Auditing Tools

---

## 1. Slack Integration with Jenkins

Slack integration allows Jenkins pipelines to **post build status notifications** directly to Slack channels. This is useful for monitoring pipeline success/failure in real time.

### 🔧 Setup Steps

1. **Install Slack Plugin in Jenkins**

    * Navigate to:
      `Manage Jenkins → Plugin Manager → Available`
    * Search for **Slack Notification** plugin.
    * Install and restart Jenkins if required.

2. **Configure Slack**

    * Open Slack (web or desktop app).
    * Log in and select/create a **workspace**.
    * Create a **channel** (e.g., `#test`).
    * Open:
      `Settings & Administration → Manage Apps`.
    * Search for **Jenkins CI** → click **Add to Slack**.
    * Select the channel you want Jenkins to post into.

3. **Configure Jenkins Slack Section**

    * Go to: `Manage Jenkins → Configure System → Slack` section.
    * **Workspace**: Enter the **team subdomain** from Slack (e.g., `myworkspace.slack.com` → subdomain = `myworkspace`).
    * **Credentials**:

        * Click **Add → Secret text**.
        * In **Secret**, paste the **Slack Integration Token** (from Slack app setup).
        * Give it an **ID** (e.g., `slack`).
    * **Default channel/member ID**: Enter the Slack channel name (e.g., `#test`).
    * Click **Test Connection** → should return success.
    * Save changes.

---

### 🚀 Usage in Jobs

#### Freestyle Jobs

* Add a **Post-build Action** → **Slack Notifications**.
* Select the desired notification type (success, failure, etc.).

#### Pipeline Jobs

Use the `slackSend` step in the pipeline script:

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Running build..."
            }
        }
    }

    post {
        success {
            slackSend(color: "#00ffcc", message: "✅ Pipeline succeeded")
        }
        failure {
            slackSend(color: "#cc3300", message: "❌ Pipeline failed")
        }
    }
}
```

⚠️ Note:

* `failure` is triggered if the pipeline stage fails (e.g., Docker command not found), **not** if there’s a Groovy syntax error in the Jenkinsfile.

---

## 2. Auditing Jenkins with Audit Log Plugin

The **Audit Log** plugin helps track "who did what" in Jenkins (security and compliance).

### 🔧 Setup Steps

1. Go to:
   `Manage Jenkins → Plugin Manager → Available`
2. Search for **Audit Trail** or **Audit Log** (plugin names may differ).

    * ✅ (AI: not accurate) — In newer Jenkins versions the recommended plugin is **Audit Trail**, not "audit log". It provides request logging into a file. Some Jenkins distributions may show "audit log" plugin, but "Audit Trail" is more widely supported.
3. Install the plugin.
4. After installation, an **Audit Logs** menu item will appear in the Jenkins dashboard.
5. Open `Audit Logs` → view `audit.html` to see detailed activity logs.

---

## 📌 Best Practices

* For **Slack tokens**, prefer **Slack App with Bot Token** instead of legacy integration tokens (legacy integrations are deprecated).
* Limit the Slack bot scope to **only channels Jenkins needs**.
* For **audit logs**, forward them to a central log system (ELK, Splunk, CloudWatch) instead of relying solely on Jenkins UI.