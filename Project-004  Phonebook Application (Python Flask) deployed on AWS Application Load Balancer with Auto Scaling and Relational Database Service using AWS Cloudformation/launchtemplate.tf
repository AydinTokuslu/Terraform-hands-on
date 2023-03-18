resource "aws_launch_template" "my_launch_template" {
  name = "my-launch-template"
  description = "My Launch Template"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type

  vpc_security_group_ids = ["${aws_security_group.vpc-web.id}"]
  
  key_name = var.instance_keypair  
  user_data = filebase64("${path.module}/app1-install.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server of Phonebook App"
    }
  }
}