

# CUSTOM CONFIGURATION    #
# Let 'waf' script change #

variable "customer" {
    description = "[REQUIRED] Customer/Project Name (max 15 characters):"
    default     = "ag"
}

variable "CloudFrontAccessLogBucket" {
    description = "[REQUIRED] CDN S3 Logs Bucket:"
    default     = "s3-ag-waf"
}

# REGION - us-east-1 #
# Used by modules - DO NOT REMOVE!
variable "aws_region" {
    description = "AWS US-West-2 region"
    default     = "us-west-2"
}

# GET AWS ACCOUNT #
data "aws_caller_identity" "current" { }
output "account_id" {
    value = "${data.aws_caller_identity.current.account_id}"
}
