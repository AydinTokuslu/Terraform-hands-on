# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "www.devopsaydintokuslu.online"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.lb.public_ip]
# }

# data "aws_acm_certificate" "issued" {
#   domain   = "tf.example.com"
#   statuses = ["ISSUED"]
# }

variable "my_domain_name" {
  default = "devopsaydintokuslu.online"
}

# https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html
# "To use an ACM Certificate with CloudFront, you must request or import the certificate in the US East (N. Virginia) region."
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias      = "acm_provider"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "my_distribution" {
  aliases = ["${var.my_domain_name}"]

  # LOTS OF OTHER CONFIG GOES HERE

  # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#viewer-certificate-arguments
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.my_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
resource "aws_acm_certificate" "my_cert" {
  provider          = "aws.acm_provider" # because ACM needs to be used in the "us-east-1" region
  domain_name       = var.my_domain_name
  validation_method = "DNS"
}

# https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html
resource "aws_acm_certificate_validation" "my_cert_validation" {
  provider                = "aws.acm_provider" # because ACM needs to be used in the "us-east-1" region
  certificate_arn         = aws_acm_certificate.my_cert.arn
  validation_record_fqdns = ["${aws_route53_record.my_cert_validation.fqdn}"]
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "my_cert_validation" {
  name    = aws_acm_certificate.my_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.my_cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.my_zone.zone_id
  records = ["${aws_acm_certificate.my_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}
