

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.33"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS and nodes"
}

variable "bastion_sg_id" {
  type        = string
  description = "Bastion SSH SG for worker nodes"
}

variable "node_instance_type" {
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 1
}


variable "cluster_role_arn" {
  type        = string
  description = "Existing EKS cluster IAM role ARN"
}

variable "node_role_arn" {
  type        = string
  description = "Existing EKS node IAM role ARN"
}

