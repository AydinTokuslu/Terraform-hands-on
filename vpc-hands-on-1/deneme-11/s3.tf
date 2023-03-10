resource "aws_s3_bucket" "kittens-carousel1" {
    bucket = "${var.bucket_name}" 
    acl = "${var.acl_value}"   
}

variable "bucket_name" {}

variable "acl_value" {
    default = "private"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

module "s3" {
    source = "<path-to-S3-folder>"
    #bucket name should be unique
    bucket_name = "kittens-carousel1"       
}