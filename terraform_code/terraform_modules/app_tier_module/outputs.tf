output "app_tier_alb_dns" {
  value = aws_lb.app_tier_alb.dns_name
}

output "app_tier_tg_arn" {
  value = aws_lb_target_group.app_tier_tg.arn
}