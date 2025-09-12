variable "vpc_id" {
  description = "Id of the vpc"
}

variable "web_tier_sg_id" {
  description = " id of the web tier sg"
  type        = string
}

variable "pub_sub1_id" {
  description = "id of the public subnet1"
  type        = string
}

variable "pub_sub2_id" {
  description = "id of the public subnet2"
  type        = string
}

variable "ami" {
  type        = string
  description = "ami id of the instances"
}

variable "instance_type" {
  type        = string
  description = "instace type value of the instances"
}

variable "key_name" {
  type        = string
  description = "name of the aws key name"
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