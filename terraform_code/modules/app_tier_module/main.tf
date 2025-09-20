resource "aws_lb" "app_tier_alb" {
  name               = "app-tier-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.app_alb_sg_id]
  subnets            = [var.pvt_sub1_id, var.pvt_sub2_id]

  enable_deletion_protection = false

  tags = {
    Name         = "app-server"
    Architecture = "three-tier"
    Role         = "app"
  }
}

resource "aws_lb_target_group" "app_tier_tg" {
  name        = "APP-ALB-Target-Group"
  protocol    = "HTTP"
  port        = 3000
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/healthz"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
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
  #user_data                   = base64encode(file("${path.module}/userdata.sh"))
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_host           = var.db_host,
    db_user           = var.db_user,
    db_pass           = var.db_pass,
    db_name           = var.db_name,
    aws_root_access_key = var.aws_root_access_key,
    aws_root_secret_key = var.aws_root_secret_key
  }))


  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "app-server"
      Architecture = "three-tier"
      Role         = "app"
    }
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
  health_check_grace_period = 300
  tag {
    key                 = "Role"
    value               = "app"
    propagate_at_launch = true
  }
  
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.MyAppASG.name
  lb_target_group_arn    = aws_lb_target_group.app_tier_tg.arn
}

data "aws_autoscaling_group" "app_asg" {
  name = aws_autoscaling_group.MyAppASG.name
}

# Get running EC2 instances with Role = app
data "aws_instances" "app_instances" {
  filter {
    name   = "tag:Role"
    values = ["app"]
  }
}

data "aws_instance" "app_instance_details" {
  for_each    = toset(data.aws_instances.app_instances.ids)
  instance_id = each.value
}