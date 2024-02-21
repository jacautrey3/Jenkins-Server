output "url-jenkins" {
  value = "http://${aws_instance.jenkins-ec2.public_ip}:8080"
}
