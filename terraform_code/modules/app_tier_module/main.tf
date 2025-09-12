resource "aws_lb" "app_tier_alb" {
  name               = "app-tier-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.app_tier_sg_id]
  subnets            = [var.pvt_sub1_id, var.pvt_sub2_id]

  tags = {
    Architecture = "three-tier"
  }
}

resource "aws_lb_target_group" "app_tier_tg" {
  name     = "APP-ALB-Target-Group"
  protocol = "HTTP"
  port     = 80
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    port     = "traffic-port"
    interval = 30
    timeout  = 5
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_tier_alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.app_tier_tg.arn
    type             = "forward"
  }

  tags = {
    Architecture = "three-tier"
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

}

resource "aws_autoscaling_group" "MyAppASG" {
  name                 = "App-Auto-Scaling-Group"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_size
  launch_template {
    id      = aws_launch_template.app_servers_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [var.pvt_sub1_id, var.pvt_sub2_id]
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.MyAppASG.name
  lb_target_group_arn    = aws_lb_target_group.app_tier_tg.arn
}