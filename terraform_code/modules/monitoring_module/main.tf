###########################
# Create SNS topic & subscription (optional)
###########################
resource "aws_sns_topic" "cpu_alerts" {
  name = var.sns_topic_name
}

# If you want email subscription, for example:
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = var.email # <-- Replace with your email or other endpoint
}

###########################
# CloudWatch Metric Alarm for high CPU on the ASG
###########################
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "AppTier-ASG-HighCPU"
  alarm_description   = "Triggered when average CPU utilization across the ASG is >= ${var.cpu_threshold_high}%"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = var.evaluation_periods
  period             = var.cpu_period
  threshold          = var.cpu_threshold_high

  namespace   = "AWS/EC2"
  statistic   = "Average"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.cpu_alerts.arn]
  ok_actions    = [aws_sns_topic.cpu_alerts.arn]

  # Handle missing data as you prefer
  treat_missing_data = "missing"
}
