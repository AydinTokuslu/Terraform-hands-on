# EC2 Instance
resource "aws_instance" "myec2vm" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = var.instance_type
  user_data              = file("${path.module}/app1-install.sh")
  key_name               = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-web.id]
  tags = {
    "Name" = "EC2 Demo 2"
  }
}
