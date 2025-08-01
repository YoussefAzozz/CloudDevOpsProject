

variable "instance_type" {
  description = "Instance type"
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the existing EC2 Key Pair"
  type        = string
}

# variable "ami_id" {
#   description = "Ubuntu 22.04 AMI for us-east-1"
#   default     = "ami-0a7d80731ae1b2435" # Canonical Ubuntu 22.04 LTS
# }



variable "subnet_id" {
  type = string
}

variable "security_group_id_controller" {
  type = string
}


variable "security_group_id_slave" {
  type = string
}

variable "instance_profile" {
  type = string
  default = null
}
