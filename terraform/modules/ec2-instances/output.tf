

output "instance_profile" {
  value = aws_iam_instance_profile.jenkins_agent_instance_profile.name
}
