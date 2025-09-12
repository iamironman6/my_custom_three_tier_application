resource "aws_instance" "db_server1" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [ var.db_tier_sg_id ]
  subnet_id = var.pvt_sub1_id
  associate_public_ip_address = false
  key_name = var.key_name
  user_data = file("${path.module}/userdata.sh")
  
  tags = {
    tier = "db"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "db_server2" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [ var.db_tier_sg_id ]
  subnet_id = var.pvt_sub2_id
  associate_public_ip_address = false
  key_name = var.key_name
  user_data = file("${path.module}/userdata.sh")
  
  tags = {
    tier = "db"
  }

  lifecycle {
    create_before_destroy = true
  }
}