# Web-Tier-Security-Group

resource "aws_security_group" "web-tier-sg" {
  description = "Allow Traffic from/to internet"
  vpc_id      = var.vpc_id
  tags = {
    Name = "web-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_https_traffic" {
  description       = "Allow HTTPS traffic to web-tier instances from internet"
  security_group_id = aws_security_group.web-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_http_traffic" {
  description       = "Allow HTTP traffic to web-tier instances from internet"
  security_group_id = aws_security_group.web-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_web_traffic" {
  description       = "Allow outbound web traffic to web tier servers"
  security_group_id = aws_security_group.web-tier-sg.id
  cidr_ipv4         = var.app_tier_subnet
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
}

# App-Tier-Secutiy-Group

resource "aws_security_group" "app-tier-sg" {
  description = "Allow Traffic from/to web-tier-sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "app-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_app_traffic" {
  description       = "Allow application traffic to app-tier from web-tier"
  security_group_id = aws_security_group.app-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = var.web_tier_subnet
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_db_traffic" {
  description       = "Allow traffic to app-tier SQL Port from web-tier"
  security_group_id = aws_security_group.app-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = var.db_tier_subnet
}

# DataBase-Tier-Security-Group

resource "aws_security_group" "db-tier-sg" {
  description = "Allow Traffic from/to db-tier-sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "db-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_db_traffic" {
  description       = "Allow database traffic to db-tier from web-tier"
  security_group_id = aws_security_group.db-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = var.app_tier_subnet
}

# Bastion-Host or Jump Server Security Group

resource "aws_security_group" "bastion-host-sg" {
  description = "Allow Traffic from/to Bastion Host"
  vpc_id      = var.vpc_id
  tags = {
    Name = "jump-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_access_to_bastion" {
  description       = "Allow SSH access to Bastion Host"
  security_group_id = aws_security_group.bastion-host-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "192.168.1.12/32" # it should be replaced with our trusted IP address like our laptop
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_access_to_private_servers" {
  description       = "Allow SSH access to Private Servers from Bastion Host"
  security_group_id = aws_security_group.bastion-host-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "10.0.0.0/18" # this should be the IP addresses range of private servers
}