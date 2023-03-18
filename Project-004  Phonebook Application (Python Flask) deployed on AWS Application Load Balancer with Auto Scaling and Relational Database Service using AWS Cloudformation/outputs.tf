output "aws_lb" {
  description = "Phonebook Application Load Balancer DNS Name"
  value = "http://${aws_lb.front.dns_name}"
}
