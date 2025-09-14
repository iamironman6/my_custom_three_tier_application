variable "asg_name" {
  description = "Name of the autoscaling group to monitor"
  type        = string
}

variable "cpu_threshold_high" {
  description = "CPU utilization threshold to trigger high alarm (in %)"
  type        = number
  default     = 80
}

variable "cpu_period" {
  description = "Period in seconds for the CloudWatch CPU metric evaluation"
  type        = number
  default     = 120
}

variable "evaluation_periods" {
  description = "Number of periods for which the alarm must be in breach before triggering"
  type        = number
  default     = 2
}

variable "sns_topic_name" {
  description = "SNS topic to send alarm notifications"
  type        = string
  default     = "app-tier-cpu-alerts"
}

variable "email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}
