output "db_instance_private_ips" {
  description = "List of DB server private IPs"
  value       = [
    aws_instance.db_server1.private_ip,
    aws_instance.db_server2.private_ip
  ]
}