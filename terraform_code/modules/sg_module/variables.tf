/*variable "web_tier_subnet" {
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
}*/

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to associate with the security group"
}

variable "bastion_public_ip" {
  type = string
}