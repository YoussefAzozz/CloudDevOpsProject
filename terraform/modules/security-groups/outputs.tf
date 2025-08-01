

output "public_ssh_sg_id" {
  value = aws_security_group.public_ssh.id
}

output "private_ssh_sg_id" {
  value = aws_security_group.private_ssh.id
}


output "security_group_id_controller" {
  value = aws_security_group.jenkins_sg_controller.id
}

output "security_group_id_slave" {
  value = aws_security_group.jenkins_sg_slave.id
}
