variable "vpc_cidr_block_value" {
  description = "Value for vpc cidr block"
}

variable "pubsub1_cidr_block_value" {
  description = "Value for first public subnet cidr block"

}

variable "pvtsub1_cidr_block_value" {
  description = "Value for first private subnet cidr block"

}

variable "pubsub2_cidr_block_value" {
  description = "Value for second public subnet cidr block"

}

variable "pvtsub2_cidr_block_value" {
  description = "Value for second private subnet cidr block"

}

variable "web_tier_subnet" {
  type        = string
  description = "Subnet value for the web-tier servers/applications"
}

variable "app_tier_subnet" {
  type        = string
  description = "Subnet value for the app-tier servers/applications"
}

variable "db_tier_subnet" {
  type        = string
  description = "Subnet value for the db-tier servers/applications"
}

variable "web_tier_ami" {
  type        = string
  description = "ami id of the instances"
}

variable "web_tier_instance_type" {
  type        = string
  description = "instace type value of the instances"
}


variable "web_tier_instance_min_size" {
  type    = number
  default = 1
}

variable "web_tier_instance_max_size" {
  type    = number
  default = 5
}

variable "web_tier_instance_desired_size" {
  type    = number
  default = 2
}

variable "app_tier_instance_ami_id" {
  type        = string
  description = "ami id of the instance"
}

variable "app_tier_instance_type" {
  type        = string
  description = "value of the instance type"
}

variable "app_tier_instance_min_size" {
  type    = number
  default = 1
}

variable "app_tier_instance_max_size" {
  type    = number
  default = 5
}

variable "app_tier_instance_desired_size" {
  type    = number
  default = 2
}

variable "db_tier_instance_ami_id" {
  type = string
}

variable "db_tier_instance_type" {
  type = string
}


variable "bastion_module_ami_id" {
  type = string
}

variable "bastion_module_instance_type" {
  type = string
}
