variable "hosted_zone_name" {
  description = "The DNS name of an existing Amazon Route 53 hosted zone, e.g., clarusway.us."
}

variable "domain_name" {
  default = "hayvanhaklari.devopsaydintokuslu.online"
  description = "The full domain name for the web application, e.g., kittens.clarusway.us."
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.domain_name}.kittens"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.kittens_bucket.id
  key    = "index.html"
  source = "https://raw.githubusercontent.com/AydinTokuslu/my-projects/main/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/index.html"
}

resource "aws_s3_bucket_object" "kitten1_jpg" {
  bucket = aws_s3_bucket.kittens_bucket.id
  key    = "kitten1.jpg"
  source = "https://raw.githubusercontent.com/AydinTokuslu/my-projects/main/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/kitten1.jpg"
}

resource "aws_s3_bucket_object" "kitten2_jpg" {
  bucket = aws_s3_bucket.kittens_bucket.id
  key    = "kitten2.jpg"
  source = "https://raw.githubusercontent.com/AydinTokuslu/my-projects/main/aws/Project-006-kittens-carousel-static-web-s3-cf/static-web/kitten2.jpg"
}




resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases = ["${var.domain_name}"]

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl = 0
    max_ttl = 31536000
    default_ttl = 86400

    compress = true
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:731967392843:certificate/97260858-0806-416b-8178-e309a902c48f"
    ssl_support_method  = "sni-only"
  }

  http_version = "http2"
  price_class  = "PriceClass_100"
}

resource "aws_route53_record" "cloudfront_distribution_dns_record" {
  zone_id = "${data.aws_route53_zone.hosted_zone.id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name    = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
    zone_id = "Z2FDTNDATAQYW2"  # This is the hard-coded zone ID for the CloudFront alias target
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = "${var.hosted_zone_name}"
}

output "domain_name" {
  value = "${var.domain_name}"
}

output "cloudfront_distribution_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}

output "website_bucket_name" {
  value = "${aws_s3_bucket.website_bucket.id}"
}