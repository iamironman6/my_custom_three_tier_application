output "web_tier_sg_id" {
  value = aws_security_group.web-tier-sg.id
}

output "app_tier_sg_id" {
  value = aws_security_group.app-tier-sg.id
}

output "db_tier_sg_id" {
  value = aws_security_group.db-tier-sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion-host-sg.id
}