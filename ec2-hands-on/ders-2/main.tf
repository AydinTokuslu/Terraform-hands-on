provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

locals {
  mytag  = "oliver-local-name"
  myname = "oliver-local-name"
}

resource "aws_instance" "tf-ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  key_name      = "second-key"
  #count = 2
  tags = {
    Name = "${local.mytag}-instance"
  }
}

resource "aws_s3_bucket" "tf-s3" {
  # bucket = "var.s3_bucket_name.${count.index}"
  # count = var.num_of_buckets
  # count = var.num_of_buckets != 0 ? var.num_of_buckets : 1
  for_each = toset(var.users)
  bucket   = "aydin-tf-s3-bucket-${each.value}"
}

# resource "aws_iam_user" "new_users" {
#   for_each = toset(var.users)
#   name     = each.value
# }
