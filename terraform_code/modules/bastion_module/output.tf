output "jump_server_public_ip" {
  description = "Public IP address of the bastion host"
  value = aws_instance.jump-server.public_ip
}