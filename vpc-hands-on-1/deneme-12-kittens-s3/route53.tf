module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "2.10.2"
}

resource "aws_route53_record" "cloudfront_distribution_dns_record" {
  zone_id = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
  name    = "hayvanhaklari"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# data "aws_route53_zone" "hosted_zone" {
#   name = var.hosted_zone_name
# }

output "domain_name" {
  value = var.domain
}

# output "route53_domain" {
#   value = aws_route53_record.cloudfront_distribution_dns_record.route53_record_fqdn
# }
