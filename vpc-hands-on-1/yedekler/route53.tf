module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "2.10.2"
}

# module "zones" {
#   source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "2.10.2"

#   zones = {
#     "hayvanhaklari.devopsaydintokuslu.online" = {
#       comment = "hayvanhaklari.devopsaydintokuslu.online"
#       tags = {
#         env = "production"
#       }
#     }

#     "myapp.com" = {
#       comment = "myapp.com"
#     }
#   }

#   tags = {
#     ManagedBy = "Terraform"
#   }
# }

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  #zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name = "hayvanhaklari"
      type = "A"
      alias = {
        name    = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      }
    }
    # {
    #   name = ""
    #   type = "A"
    #   ttl  = 3600
    #   records = [
    #     "10.10.10.10",
    #   ]
    # },
  ]

  #depends_on = [module.zones]
}

output "route53_domain" {
  value = module.records.route53_record_fqdn
}
