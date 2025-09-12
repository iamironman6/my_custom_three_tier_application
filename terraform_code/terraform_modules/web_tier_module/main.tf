resource "aws_lb" "web_tier_alb" {
  name               = "web-tier-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_tier_sg_id]
  subnets            = [var.pub_sub1_id, var.pub_sub2_id]

  tags = {
    Architecture = "three-tier"
  }
}

resource "aws_lb_target_group" "web_tier_tg" {
  name     = "ALB-Target-Group"
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

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web_tier_alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.web_tier_tg.arn
    type             = "forward"
  }

  tags = {
    Architecture = "three-tier"
  }
}

resource "aws_launch_configuration" "web_servers_template" {
  name_prefix                 = "web_server_"
  instance_type               = var.instance_type
  image_id                    = var.ami
  security_groups             = [var.web_tier_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "MyASG" {
  name                 = "Web-Auto-Scaling-Group"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_size
  launch_configuration = aws_launch_configuration.web_servers_template.arn
  vpc_zone_identifier  = [var.pub_sub1_id, var.pub_sub2_id]
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.MyASG.name
  lb_target_group_arn    = aws_lb_target_group.web_tier_tg.arn
}


