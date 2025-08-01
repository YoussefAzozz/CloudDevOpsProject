

variable "vpc_id" {
  type        = string
  description = "The VPC ID to attach security groups to"
}

variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR notation (e.g. 1.2.3.4/32)"
}
