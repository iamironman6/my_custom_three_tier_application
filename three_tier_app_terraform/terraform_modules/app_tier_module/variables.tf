variable "vpc_id" {
  type = string
}

variable "key_name" {
  type        = string
  description = "key file for login into instances"
}

variable "ami_id" {
  type        = string
  description = "ami id of the instance"
}

variable "instance_type" {
  type        = string
  description = "value of the instance type"
}

variable "app_tier_sg_id" {
  type        = string
  description = "id of the app tier security group"
}

variable "pvt_sub1_id" {
  type        = string
  description = "id of the private subnet1"
}

variable "pvt_sub2_id" {
  type        = string
  description = "id of the private subnet2"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 5
}

variable "desired_size" {
  type    = number
  default = 2
}