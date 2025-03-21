
data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "cacheOptimized" {
  name = "Managed-CachingOptimized"
}


#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "acm_https_cert_arn" {
  name = "/${var.project_name}/${var.environment}/acm_https_cert_arn"
}
