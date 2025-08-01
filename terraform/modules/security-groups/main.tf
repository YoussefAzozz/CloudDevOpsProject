

# Public SG - allow SSH from your IP
resource "aws_security_group" "public_ssh" {
  name        = "public-ssh-sg"
  description = "Allow SSH from my IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-ssh-sg"
  }
}

# Private SG - allow SSH only from the bastion SG
resource "aws_security_group" "private_ssh" {
  name        = "private-ssh-sg"
  description = "Allow SSH from Bastion only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ssh-sg"
  }
}


# ALB SG - Allow HTTP from your IP
resource "aws_security_group" "alb_http" {
  name        = "alb-http-sg"
  description = "Allow HTTP from my IP to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-http-sg"
  }
}





resource "aws_security_group" "alb-access-app" {
  name        = "alb-access-app"
  description = "Allow access to the app from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from ALB"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-access-app"
  }
}


resource "aws_security_group" "jenkins_sg_controller" {
  name        = "jenkins-sg-controller"
  description = "Allow SSH and Jenkins for Controller"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jenkins_sg_slave" {
  name        = "jenkins-sg-slave"
  description = "Allow SSH and Jenkins for Slave"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg_controller.id]
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_security_group" "argocd-sg" {
  name        = "argocd-sg"
  description = "Allow ALB to access ArgoCD"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow ALB to access ArgoCD server"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

