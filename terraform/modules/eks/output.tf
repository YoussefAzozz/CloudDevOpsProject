

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-ivolve-final.endpoint
}

output "node_role_arn" {
  value = var.node_role_arn
}
