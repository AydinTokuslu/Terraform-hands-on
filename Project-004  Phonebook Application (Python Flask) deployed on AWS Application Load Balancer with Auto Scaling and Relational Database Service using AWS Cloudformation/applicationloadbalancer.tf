resource "aws_lb" "front" {
  name               = "front"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.vpc-ssh.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front.arn
  port = "80"
  protocol = "HTTP"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }

}



