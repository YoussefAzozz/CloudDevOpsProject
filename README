<h1 align="center" style="font-size: 40px;">🚀 AWS EKS Cloud-Native Deployment with CI/CD, Monitoring, and Secrets Management</h1>

<h3 align="center">End-to-End Cloud-Native Application Deployment on AWS EKS with Terraform, Ansible, Jenkins, and Kubernetes Best Practices</h3>

---

<h2>📖 Project Overview</h2>

This project demonstrates the end-to-end deployment of a **cloud-native application** on **Amazon Elastic Kubernetes Service (EKS)** using a fully automated **DevOps pipeline**. The setup emphasizes **security, scalability, observability, and best practices** for Kubernetes workload orchestration on AWS.  

Key highlights of this project include:

- Automated **EKS Cluster Provisioning** with **Terraform**.
- **Application and Database Node Groups** with **taints and node affinity** for strict workload scheduling.
- Secure **storage provisioning** using **Amazon EBS CSI Driver**.
- **Path-based Ingress Routing** with **AWS ALB Ingress Controller**.
- **Continuous Integration and Delivery (CI/CD)** with **Jenkins**.
- **Secrets Management** with **AWS Secrets Manager & CSI Driver** (no plain `kubectl apply -f secrets.yml`).
- **Centralized Logging** with **Fluent Bit to CloudWatch**.
- **Infrastructure Configuration Management** with **Ansible**.

---

<h2>🏗️ Architecture</h2>

The architecture of the project consists of the following components:

1. <b>EKS Cluster</b>
   - Provisioned with Terraform.
   - <b>Two Managed Node Groups</b>:
     - <b>App Node Group</b> → Hosts application workloads.
     - <b>Database Node Group</b> → Hosts database pods.
   - <b>Taints and Node Affinity</b> applied to ensure workloads are scheduled on their dedicated nodes.

2. <b>Storage and Ingress</b>
   - <b>Amazon EBS CSI Driver</b>:
     - Dynamically provisions persistent volumes.
     - IAM Role with policies for volume create, attach, and detach operations.
   - <b>AWS ALB Ingress Controller</b>:
     - Provides external access to services via Application Load Balancer.
     - <b>Path-based routing</b>:
       - `/` → Application service
       - `/argocd` → Argo CD service

3. <b>Argo CD</b>
   - Installed and configured in the cluster.
   - Default route updated from `/` to `/argocd` for secure dashboard access.

4. <b>CI/CD with Jenkins</b>
   - <b>Jenkins Cluster</b>:
     - Jenkins Controller + Jenkins Slave.
     - Jenkins Slave IAM role has <b>ECR access</b> for pulling/pushing images.
   - <b>Pipeline Workflow</b>:
     1. Pull source code and run test cases.
     2. Build Docker image.
     3. Push image to <b>Amazon ECR</b>.
     4. Deploy the app to the EKS cluster.
   - Fully automated with webhooks or manual triggers.

5. <b>Secrets Management</b>
   - <b>AWS Secrets Manager</b> for database and application credentials.
   - <b>Secrets Store CSI Driver + AWS Provider</b>:
     - Mounts secrets directly to pods securely.
     - IAM Role + ServiceAccount for CSI access.

6. <b>Monitoring and Logging</b>
   - <b>Fluent Bit</b> agent installed as DaemonSet.
   - IAM Role with permissions to push logs to <b>Amazon CloudWatch</b>.
   - Logs collected from worker nodes and pods for centralized observability.

7. <b>Infrastructure as Code & Automation</b>
   - <b>Terraform</b> → For full infrastructure provisioning.
   - <b>Ansible</b> → For post-deployment configuration management.
   - <b>Jenkins</b> → For application build and deployment automation.

---

<h2>⚙️ Tech Stack</h2>

- **Cloud Provider**: AWS (EKS, ECR, CloudWatch, Secrets Manager, IAM)
- **Container Orchestration**: Kubernetes on EKS
- **CI/CD**: Jenkins
- **Infrastructure as Code**: Terraform
- **Configuration Management**: Ansible
- **Ingress & Load Balancing**: AWS ALB Ingress Controller
- **Storage**: Amazon EBS CSI Driver
- **Secrets Management**: AWS Secrets Manager + CSI Driver
- **Logging**: Fluent Bit + CloudWatch
- **Containerization**: Docker

---

<h2>📂 Project Highlights</h2>

- ✅ Secure, scalable, and automated Kubernetes deployment on AWS.
- ✅ Zero manual secret management using AWS Secrets Manager + CSI Driver.
- ✅ End-to-end DevOps workflow:
  - **Build → Test → Dockerize → Push → Deploy → Monitor**
- ✅ Full compliance with AWS best practices for IAM roles and service accounts.
- ✅ Clear separation of application and database workloads using **node taints and affinities**.

---

<h2>🚀 Outcome</h2>

This project demonstrates **enterprise-grade cloud-native deployment** with:

- **High availability**: Isolated node groups and managed scaling.
- **Security first**: IAM roles for each Kubernetes service and no plain-text secrets.
- **Observability**: Centralized logging to CloudWatch for better insights.
- **Full automation**: Terraform + Ansible + Jenkins reduce manual intervention.
