

resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id_controller]
  associate_public_ip_address = true
  tags = {
    Name = "jenkins-controller"
    Role = "jenkins-controller"
  }
  depends_on = [ var.security_group_id_controller ]
}


resource "aws_instance" "jenkins_slave" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id_slave]
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile
  tags = {
    Name = "jenkins-slave"
    Role = "jenkins-slave"
  }
  depends_on = [ aws_iam_instance_profile.jenkins_agent_instance_profile , var.security_group_id_slave ]
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (official Ubuntu publisher)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

