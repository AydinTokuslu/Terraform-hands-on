variable "aws_region" {
  default = "us-east-1"
}

variable "domain" {
  default = "hayvanhaklari.devopsaydintokuslu.online"
}

variable "acm_certificate_arn" {
  description = "Existing ACM Certificate ARN"
  default     = false
  type        = string
}

provider "aws" {
  region = var.aws_region
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.domain
  acl    = "public-read"

  versioning = {
    enabled = false
  }

}

# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951
# resource "aws_s3_bucket" "site" {
#   bucket = var.domain
#   acl    = "public-read"

#   policy = <<EOF
#     {
#       "Version":"2008-10-17",
#       "Statement":[{
#         "Sid":"AllowPublicRead",
#         "Effect":"Allow",
#         "Principal": {"AWS": "*"},
#         "Action":["s3:GetObject"],
#         "Resource":["arn:aws:s3:::${var.domain}/*"]
#       }]
#     }
#   EOF

#   website {
#     index_document = "index.html"
#   }
# }

resource "aws_s3_bucket_policy" "b" {
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
            "Resource":["arn:aws:s3:::${var.domain}/*"]
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


resource "aws_s3_bucket_object" "object1" {
  for_each = fileset("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/", "*")
  bucket   = var.domain
  key      = each.value
  source   = "C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}"
  etag     = filemd5("C:/Users/aydin/Desktop/my-projects/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/${each.value}")
}

# Note: Creating this route53 zone is not enough. The domain's name servers need to point to the NS
# servers of the route53 zone. Otherwise the DNS lookup will fail.
# To verify that the dns lookup succeeds: `dig site @nameserver`
resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "root_domain" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = var.domain
    domain_name = "${var.domain}.s3.amazonaws.com"
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["${var.domain}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

#   viewer_certificate = {
#     acm_certificate_arn = "arn:aws:acm:us-east-1:731967392843:certificate/97260858-0806-416b-8178-e309a902c48f"
#     ssl_support_method  = "sni-only"
#   }

  viewer_certificate {    
    acm_certificate_arn            = "arn:aws:acm:us-east-1:731967392843:certificate/97260858-0806-416b-8178-e309a902c48f"
    ssl_support_method             = "sni-only"
    #minimum_protocol_version       = var.viewer_minimum_protocol_version
    #cloudfront_default_certificate = var.acm_certificate_arn ? false : true
  }
  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }


}

output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "route53_domain" {
  value = aws_route53_record.root_domain.fqdn
}

output "cdn_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
