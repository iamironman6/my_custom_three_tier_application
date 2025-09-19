variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "bastion_host_sg_id" {
  type = string
}

variable "pub_sub1_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "app_instance_private_ips" {
  type        = list(string)
  description = "Private IPs of all App tier instances"
}

variable "db_instance_private_ips" {
  type        = list(string)
  description = "List of DB tier instance private IPs"
}