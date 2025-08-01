#!/usr/bin/bash

#update the kubeconfig file to authenticate to the EKS Cluster
aws eks update-kubeconfig --region us-east-1 --name eks-ivolve-final

#Enable OpenConnectID(OIDC) to the cluster
eksctl utils associate-iam-oidc-provider \
  --cluster eks-ivolve-final \
  --approve

#Create serviceaccount and role for the EBS-CSI with IAM-Polcies to create and attach EBS-Volumes to the pods
eksctl create iamserviceaccount \
  --region us-east-1 \
  --cluster eks-ivolve-final \
  --namespace kube-system \
  --name ebs-csi-controller-sa \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-name AmazonEKS_EBS_CSI_DriverRole

#Install EBS-CSI in the EKS Cluster with NodeAffinity to ensure that it scheduled on the selected node where the database pods are running
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=ebs-csi-controller-sa \
  --set node.tolerations[0].key=workload \
  --set node.tolerations[0].operator=Equal \
  --set node.tolerations[0].value=database \
  --set node.tolerations[0].effect=NoSchedule \
  --set node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=workload \
  --set node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=In \
  --set node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=database

#---------------------------------------------------------------------------------------------------------------

#			Configure Application Load Balancer as Ingress Controller of the cluster


#Create serviceaccount and role for the ALB-Controller with IAM-Polcies to create ALB ingress controller for the cluster
eksctl create iamserviceaccount \
  --cluster eks-ivolve-final \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::242201296834:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

#Intsall the ALB Controller in the cluster and attach the serviceaccount and role to apply its roles
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-ivolve-final \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0bee85e7498ba47e6

#--------------------------------------------------------------------------------------------------------------------

#			Intsall and configure ArgoCD in the Cluster

#Install argocd tool in the cluster in its namespace
helm upgrade --install argocd argo/argo-cd \
  -n argocd \
  --create-namespace \
  --set configs.params."server\.insecure"=true \
  --set server.ingress.enabled=false

#Disable the https connection to the argocd(For testing) as its default connection is over https
kubectl patch configmap argocd-cmd-params-cm \
  -n argocd \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'

#Change the defualt routing traffic
kubectl patch configmap argocd-cmd-params-cm \
  -n argocd \
  --type merge \
  -p '{"data":{"server.insecure":"true","server.basehref":"/argocd","server.rootpath":"/argocd"}}'

#Restart the argocd-server deployment to get the new configuration
kubectl rollout restart deploy argocd-server -n argocd

#Read the admin password of the argocd service
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#-------------------------------------------------------------------------------------------------------

#		Install fluent-bit (Monitoring Agent) for Monitoring the nodes and the application

#Create the policy to access CloudWatch monitoring tool
aws iam create-policy \
  --policy-name FluentBitCloudWatchPolicy \
  --policy-document file://fluentbit-cloudwatch-policy.json

#Create serviceaccount and role and attach the polcies to the role
eksctl create iamserviceaccount \
  --name fluent-bit \
  --namespace logging \
  --cluster eks-ivolve-final \
  --attach-policy-arn arn:aws:iam::242201296834:policy/FluentBitPolicy \
  --approve \
  --override-existing-serviceaccounts

#This script makes the fluent-bit pods schedule only on the application nodes and database nodes
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=fluent-bit \
  --set cloudWatch.enabled=true \
  --set cloudWatch.region=us-east-1 \
  --set cloudWatch.logGroupName=/aws/containerinsights/eks-ivolve-final/application \
  --set cloudWatch.logStreamPrefix=from-fluent-bit- \
  --set cloudWatch.autoCreateGroup=true \
  --set output.elasticsearch.enabled=false \
  --set output.cloudwatch_logs.enabled=true \
  --set extraOutputs={} \
  --set tolerations[0].key=workload \
  --set tolerations[0].operator=Equal \
  --set tolerations[0].value=app \
  --set tolerations[0].effect=NoSchedule \
  --set tolerations[1].key=workload \
  --set tolerations[1].operator=Equal \
  --set tolerations[1].value=database \
  --set tolerations[1].effect=NoSchedule \
  --set affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=workload \
  --set affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=In \
  --set affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=app \
  --set affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[1]=database

#Restart the deployment pods of the fluent-bit
kubectl rollout restart ds/fluent-bit -n logging

#-------------------------------------------------------------------------------------------------------------------

#				Integrating AWS Secrets Manager with EKS ckuster

#Install the Secrets Store CSI Driver
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system

#Install AWS provider for the CSI driver
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

#Creates a policy to access the sectrets in the AWS Secrets Mnager
aws iam create-policy \
  --policy-name EKSSecretsManagerPolicy \
  --policy-document file://secretsmanager-policy.json

#Creates a serviceaccount and role and attach the created policy to the role
eksctl create iamserviceaccount \
  --name secrets-sa \
  --namespace ivolve \
  --cluster eks-ivolve-final \
  --attach-policy-arn arn:aws:iam::242201296834:policy/SecretsManagerCSIPolicy \
  --approve \
  --override-existing-serviceaccounts

#Schedule the scerets-csi driver to the nodes where the pods needs the secrets are running
kubectl -n kube-system patch daemonset csi-secrets-store-provider-aws \
  --type='json' \
  -p='[
    {"op": "add", "path": "/spec/template/spec/tolerations", "value": [{"operator":"Exists"}]},
    {"op": "add", "path": "/spec/template/spec/affinity", "value": {
        "nodeAffinity": {
          "requiredDuringSchedulingIgnoredDuringExecution": {
            "nodeSelectorTerms": [
              {
                "matchExpressions": [
                  {
                    "key": "workload",
                    "operator": "In",
                    "values": ["app","database"]
                  }
                ]
              }
            ]
          }
        }
      }
    }
  ]'


#Get the pods with the its nodes to ensure the pods are scheduled on the right nodes  
kubectl get pods -n kube-system -o wide | grep csi-secrets

