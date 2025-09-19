output "web_tier_sg_id" {
  value = aws_security_group.web_tier_sg.id
}

output "app_tier_sg_id" {
  value = aws_security_group.app_tier_sg.id
}

output "db_tier_sg_id" {
  value = aws_security_group.db-tier-sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion-host-sg.id
}

output "web_alb_sg_id" {
  value = aws_security_group.web_alb_sg.id
}

output "app_alb_sg_id" {
  value = aws_security_group.app_alb_sg.id
}