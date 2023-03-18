resource "aws_autoscaling_group" "my_asg" {
  name = "myasg"
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier  = aws_lb.front.subnets
    
  target_group_arns = [aws_lb_target_group.front.arn]
  health_check_grace_period = 300
  health_check_type = "ELB"
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = aws_launch_template.my_launch_template.latest_version
  }
  
}