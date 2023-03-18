# Create Security Group - SSH Traffic
resource "aws_security_group" "vpc-ssh" {
  name        = "ALBSecurityGroup"
  description = "ALBSecurityGroup"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALBSecurityGroup"
  }
}

# Create Security Group - Web Traffic
resource "aws_security_group" "vpc-web" {
  name        = "WebServerSecurityGroup"
  description = "WebServerSecurityGroup"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.vpc-ssh.id]
    
  }
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServerSecurityGroup"
  }
}

# Create Security Group - Web Traffic
resource "aws_security_group" "rds-sec" {
  name        = "MyDBSecurityGroup"
  description = "MyDBSecurityGroup"
  vpc_id      = module.vpc.vpc_id


  ingress {
    description = "Allow Port 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.vpc-web.id]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyDBSecurityGroup"
  }
}

