# variable "hosted_zone_name" {
#   type        = string
#   default     = "hayvanhaklari.devopsaydintokuslu.online"
#   description = "The DNS name of an existing Amazon Route 53 hosted zone, e.g., clarusway.us."
# }



variable "domain_name" {
  default     = "hayvanhaklari.devopsaydintokuslu.online"
  description = "The full domain name for the web application, e.g., kittens.clarusway.us."
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain_name
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.website_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "bucket" {
  bucket = var.domain_name

  # grant {
  #   id          = data.aws_canonical_user_id.current_user.id
  #   type        = "CanonicalUser"
  #   permissions = ["FULL_CONTROL"]
  # }

  grant {
    type        = "Group"
    permissions = ["READ_ACP", "WRITE"]
    #uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }
}

resource "aws_s3_object" "object1" {
  for_each = fileset("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/", "*")
  bucket   = aws_s3_bucket.website_bucket.id
  key      = each.value
  source   = "C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}"
  etag     = filemd5("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}")
}



resource "aws_cloudfront_origin_access_identity" "kittens_origin_access_identity" {
  comment = "Kittens origin access identity"
}

resource "aws_s3_bucket_policy" "kittens_bucket_policy" {
  bucket = var.domain_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.kittens_origin_access_identity.id}"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.domain_name}/*"
      }
    ]
  })
}

# resource "aws_s3_bucket_policy" "b3" {
#   bucket = var.domain_name
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::${var.domain_name}/*"
#         }
#     ]
# }
# POLICY
# }

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases = ["${var.domain_name}"]

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = ""
      #origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
    # custom_origin_config {
    #   http_port              = "80"
    #   https_port             = "443"
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
  }
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"


  logging_config {
    include_cookies = false
    bucket          = "${var.domain_name}.s3.amazonaws.com"
    prefix          = "myprefix"
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    max_ttl     = 31536000
    default_ttl = 86400

  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:731967392843:certificate/97260858-0806-416b-8178-e309a902c48f"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

}
module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "2.10.2"
}

# resource "aws_route53_zone" "kittens_zone" {
#   name = "devopsaydintokuslu.online"
# }

provider "aws" {
  alias = "dns_zones"
  # ... access keys etc/assume role block
}

data "aws_route53_zone" "selected" {
  #provider     = "aws.dns_zones"
  name         = "devopsaydintokuslu.online." # Notice the dot!!!
  private_zone = false
}

# data "aws_route53_zone" "selected" {
#   name         = "devopsaydintokuslu.online"
#   private_zone = true
# }

resource "aws_route53_record" "hayvanhaklari" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "hayvanhaklari.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["10.0.0.1"]
}

# resource "aws_route53_record" "cloudfront_distribution_dns_record" {
#   zone_id = aws_route53_zone.kittens_zone.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# data "archive_file" "kittens_app" {
#   type        = "zip"
#   source_dir  = "C:/Users/aydin/Desktop/kittens_app"
#   output_path = "C:/Users/aydin/Desktop/kittens_app.zip"
# }

# resource "aws_s3_bucket_object" "kittens_app" {
#   bucket = aws_s3_bucket.website_bucket.id
#   key    = "kittens_app.zip"
#   source = data.archive_file.kittens_app.output_path
# }

# data "aws_route53_zone" "hosted_zone" {
#   name = var.hosted_zone_name
# }

# output "domain_name" {
#   value = var.domain_name
# }

# output "cloudfront_distribution_domain_name" {
#   value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
# }

# output "website_bucket_name" {
#   value = aws_s3_bucket.website_bucket.id
# }

output "domain_name" {
  value = var.domain_name
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "website_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
}
