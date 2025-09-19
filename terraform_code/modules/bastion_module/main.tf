resource "aws_instance" "jump-server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = var.pub_sub1_id
  key_name                    = var.key_name
  user_data_base64 =  base64encode(templatefile("${path.module}/userdata.sh", {
    app_ips    = var.app_instance_private_ips,
    db_ips     = var.db_instance_private_ips
  }))
  tags = {
    type = "Bastion"
  }
}
