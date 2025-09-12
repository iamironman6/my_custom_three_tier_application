output "alb_name" {
  value = aws_lb.web_tier_alb.name
}

output "web_server_tg_name" {
  value = aws_lb_target_group.web_tier_tg.name
}