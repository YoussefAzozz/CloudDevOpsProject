
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "security_group" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  my_ip  = "156.208.195.36/32" # Replace with your actual public IP
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "eks-ivolve-final"
  cluster_version    = "1.33"
  private_subnet_ids = module.vpc.private_subnets
  bastion_sg_id      = module.security_group.private_ssh_sg_id
  cluster_role_arn   = "arn:aws:iam::242201296834:role/eks_role"
  node_role_arn      = "arn:aws:iam::242201296834:role/EKSNodeInstanceRole"

  node_instance_type = "t3.medium"
  node_desired_size  = 1

  depends_on = [module.vpc, module.security_group]
}


module "ec2-instance" {
  source = "./modules/ec2-instances"
  # ami_id          = "ami-0c55b159cbfafe1f0" # Replace with your actual AMI ID
  instance_type   = "t3.medium"
  key_name        = "terraform-priv-key" # Replace with your actual key name
  subnet_id = module.vpc.public_subnets[0] # Use the first public subnet
  security_group_id_controller = module.security_group.security_group_id_controller
  security_group_id_slave = module.security_group.security_group_id_slave
  instance_profile = "jenkins-agent-instance-profile" # Replace with your actual instance profile
}



