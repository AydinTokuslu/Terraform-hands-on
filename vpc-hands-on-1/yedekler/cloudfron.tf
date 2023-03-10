# module "cloudfront" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "3.2.0"
# }

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["hayvanhaklari.devopsaydintokuslu.online"]

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  logging_config = {
    bucket = "${var.domain}.s3.amazonaws.com"
    #bucket = "logs-hayvanhaklari.devopsaydintokuslu.online.s3.amazonaws.com"
  }

  origin = {
    something = {
      domain_name = "hayvanhaklari.devopsaydintokuslu.online"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }

    s3_one = {
      domain_name = "hayvanhaklari.devopsaydintokuslu.online.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "something"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_one"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:731967392843:certificate/97260858-0806-416b-8178-e309a902c48f"
    ssl_support_method  = "sni-only"
  }
}
