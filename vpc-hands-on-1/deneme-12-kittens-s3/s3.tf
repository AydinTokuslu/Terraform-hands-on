terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  required_version = ">= 1.3.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# variable "aws_region" {
#   description = "Region in which AWS Resources to be created"
#   type        = string
#   default     = "us-east-1"
# }

# module "s3-bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "3.7.0"
# }

variable "domain" {
  default = "hayvanhaklari.devopsaydintokuslu.online"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}


resource "aws_s3_object" "object1" {
  for_each = fileset("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/", "*")
  bucket   = var.domain
  key      = each.value
  source   = "C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}"
  etag     = filemd5("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}")
}

# resource "aws_iam_role" "this" {
#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::${var.domain}/*"
#         }
#     ]
# }
# EOF
# }



resource "aws_s3_bucket_policy" "b3" {
  bucket = var.domain
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.domain}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = var.domain

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

output "website_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
}
