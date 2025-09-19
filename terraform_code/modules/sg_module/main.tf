# Web ALB Security Group
resource "aws_security_group" "web_alb_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "web-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_internet" {
  security_group_id = aws_security_group.web_alb_sg.id
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_internet" {
  security_group_id = aws_security_group.web_alb_sg.id
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
}


# Web-Tier-Security-Group

resource "aws_security_group" "web_tier_sg" {
  description = "Allow Traffic from/to internet"
  vpc_id      = var.vpc_id
  tags = {
    Name = "web-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_traffic_web_tier" {
  description       = "Allow SSH traffic to web-tier instances from my PC"
  security_group_id = aws_security_group.web_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "27.6.42.76/32"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_https_traffic_from_web_alb" {
  description       = "Allow HTTPS traffic to web-tier instances from Web ALB"
  security_group_id = aws_security_group.web_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  #cidr_ipv4         = "0.0.0.0/0"
  referenced_security_group_id = aws_security_group.web_alb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_http_traffic_from_web_alb" {
  description       = "Allow HTTP traffic to web-tier instances from Web ALB"
  security_group_id = aws_security_group.web_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  #cidr_ipv4         = "0.0.0.0/0"
  referenced_security_group_id = aws_security_group.web_alb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_web_outbound" {
  security_group_id = aws_security_group.web_tier_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


/*resource "aws_vpc_security_group_egress_rule" "allow_outbound_web_traffic" {
  description       = "Allow outbound web traffic to app tier servers"
  security_group_id = aws_security_group.web_tier_sg.id
  #cidr_ipv4         = var.app_tier_subnet
  referenced_security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_http_web_traffic_to_app_tier" {
  description       = "Allow outbound http web traffic to app tier servers"
  security_group_id = aws_security_group.web_tier_sg.id
  #cidr_ipv4         = var.app_tier_subnet
  referenced_security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_https_web_traffic" {
  description       = "Allow outbound https web traffic to internet to download files from S3 bucket"
  security_group_id = aws_security_group.web_tier_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}*/


# App ALB Security Group
resource "aws_security_group" "app_alb_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "app-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_3000_from_web_tier" {
  security_group_id             = aws_security_group.app_alb_sg.id
  from_port                     = 3000
  to_port                       = 3000
  referenced_security_group_id = aws_security_group.web_tier_sg.id  # Assuming this is web EC2 SG
  ip_protocol = "tcp"
}

# App-Tier-Secutiy-Group

resource "aws_security_group" "app_tier_sg" {
  description = "Allow Traffic from/to web_tier_sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "app-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_inbound_app_tier" {
  description       = "Allow ssh traffic to app-tier from bastion host"
  security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${var.bastion_public_ip}/32"
}


resource "aws_vpc_security_group_ingress_rule" "allow_inbound_app_traffic_from_app_alb" {
  description       = "Allow application traffic to app-tier from APP ALB"
  security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  #cidr_ipv4         = var.web_tier_subnet
  referenced_security_group_id = aws_security_group.app_alb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_app_outbound" {
  security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

/*resource "aws_vpc_security_group_egress_rule" "allow_outbound_db_traffic" {
  description       = "Allow traffic to app-tier SQL Port from web-tier"
  security_group_id = aws_security_group.app_tier_sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  #cidr_ipv4         = var.db_tier_subnet
  referenced_security_group_id = aws_security_group.db-tier-sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_https_app_traffic" {
  description       = "Allow outbound https app traffic to internet to download files from S3 bucket"
  security_group_id = aws_security_group.app_tier_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}*/

# DataBase-Tier-Security-Group

resource "aws_security_group" "db-tier-sg" {
  description = "Allow Traffic from/to db-tier-sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "db-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_inbound_db_tier" {
  description       = "Allow ssh traffic to db-tier from bastion host"
  security_group_id = aws_security_group.db-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${var.bastion_public_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_db_traffic" {
  description       = "Allow database traffic to db-tier from app-tier"
  security_group_id = aws_security_group.db-tier-sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  #cidr_ipv4         = var.app_tier_subnet
  referenced_security_group_id = aws_security_group.app_tier_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_db_outbound" {
  security_group_id = aws_security_group.db-tier-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

/*resource "aws_vpc_security_group_egress_rule" "allow_outbound_https_db_traffic" {
  description       = "Allow outbound https web traffic to internet to download files from S3 bucket"
  security_group_id = aws_security_group.db-tier-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}*/

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
  cidr_ipv4         = "27.6.42.76/32" # it should be replaced with our trusted IP address like our laptop
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_access_to_app_servers" {
  description       = "Allow SSH access to APP Servers from Bastion Host"
  security_group_id = aws_security_group.bastion-host-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  #cidr_ipv4         = "10.0.0.0/18" # this should be the IP addresses range of private servers
  referenced_security_group_id = aws_security_group.app_tier_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_access_to_db_servers" {
  description       = "Allow SSH access to DB Servers from Bastion Host"
  security_group_id = aws_security_group.bastion-host-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  #cidr_ipv4         = "10.0.0.0/18" # this should be the IP addresses range of private servers
  referenced_security_group_id = aws_security_group.db-tier-sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_https_bastion_traffic" {
  description       = "Allow outbound https traffic to internet to download files from S3 bucket"
  security_group_id = aws_security_group.bastion-host-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}