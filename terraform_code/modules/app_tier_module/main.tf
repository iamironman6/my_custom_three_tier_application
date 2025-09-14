resource "aws_lb" "app_tier_alb" {
  name               = "app-tier-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.app_tier_sg_id]
  subnets            = [var.pvt_sub1_id, var.pvt_sub2_id]

  enable_deletion_protection = false

  tags = {
    Name         = "app-server"
    Architecture = "three-tier"
    Role         = "app"
  }
}

resource "aws_lb_target_group" "app_tier_tg" {
  name     = "APP-ALB-Target-Group"
  protocol = "HTTP"
  port     = 3000
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path     = "/api/data"
    port     = "traffic-port"
    interval = 30
    timeout  = 5
    matcher = "200"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_tier_alb.arn
  protocol          = "HTTP"
  port              = 3000

  default_action {
    target_group_arn = aws_lb_target_group.app_tier_tg.arn
    type             = "forward"
  }
}

resource "aws_launch_template" "app_servers_template" {
  name_prefix                 = "app_server_"
  instance_type               = var.instance_type
  image_id                    = var.ami_id
  key_name                    = var.key_name
  
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.app_tier_sg_id]
  }
  user_data                   = base64encode(file("${path.module}/userdata.sh"))

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "app-server"
    Architecture = "three-tier"
    Role         = "app"
  }
}

resource "aws_autoscaling_group" "MyAppASG" {
  name                 = "App-Auto-Scaling-Group"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_size
  vpc_zone_identifier  = [var.pvt_sub1_id, var.pvt_sub2_id]

  launch_template {
    id      = aws_launch_template.app_servers_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = "0"
  tag {
    key                 = "Name"
    value               = "AppTierInstance"
    propagate_at_launch = true
  }
  
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.MyAppASG.name
  lb_target_group_arn    = aws_lb_target_group.app_tier_tg.arn
}


#########################################
# SNS Topic for CloudWatch Alarms
#########################################

resource "aws_sns_topic" "cpu_alerts" {
  name = "app-tier-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = "saikrishnakonchada369@gamil.com"  # ✅ Replace with your actual email
}

#########################################
# CloudWatch Alarm for High CPU
#########################################

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "AppTier-ASG-HighCPU"
  alarm_description   = "High CPU on App Tier ASG"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 120
  threshold           = 80
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.MyAppASG.name
  }

  alarm_actions = [aws_sns_topic.cpu_alerts.arn]
  ok_actions    = [aws_sns_topic.cpu_alerts.arn]

  treat_missing_data = "missing"
}