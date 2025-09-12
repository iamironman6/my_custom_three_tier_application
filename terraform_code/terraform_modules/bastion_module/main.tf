resource "aws_instance" "jump-server-1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = var.pub_sub1_id
  user_data                   = file("${path.module}/userdata.sh")
  key_name                    = var.key_name

  tags = {
    type = "jump-server"
  }
}

resource "aws_instance" "jump-server-2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = var.pub_sub2_id
  user_data                   = file("${path.module}/userdata.sh")
  key_name                    = var.key_name

  tags = {
    type = "jump-server"
  }
}
