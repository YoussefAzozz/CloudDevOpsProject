

resource "aws_eks_cluster" "eks-ivolve-final" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# Managed Node Group
resource "aws_eks_node_group" "db_nodes" {
  cluster_name    = aws_eks_cluster.eks-ivolve-final.name
  node_group_name = "database-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_desired_size
    min_size     = 1
  }

  instance_types = [var.node_instance_type]

  remote_access {
    ec2_ssh_key               = "terraform-priv-key"
    source_security_group_ids = [var.bastion_sg_id]
  }

  labels = {
    workload = "database"
  }

  taint {
    key    = "workload"
    value  = "database"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "eks-database-node"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.eks-ivolve-final]
}



resource "aws_eks_node_group" "app_nodes" {
  cluster_name    = aws_eks_cluster.eks-ivolve-final.name
  node_group_name = "app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  tags = {
    Name = "eks-app-node"
  }

  depends_on = [aws_eks_cluster.eks-ivolve-final]
}


resource "aws_eks_node_group" "python-ng" {
  cluster_name    = aws_eks_cluster.eks-ivolve-final.name
  node_group_name = "python-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  instance_types = [var.node_instance_type]

  remote_access {
    ec2_ssh_key               = "terraform-priv-key"
    source_security_group_ids = [var.bastion_sg_id]
  }

  labels = {
    workload = "app"
  }

  taint {
    key    = "workload"
    value  = "app"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "eks-database-node-2"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.eks-ivolve-final]
}
