#Creating CDN Content Delivery Network

resource "aws_cloudfront_distribution" "expense" {
  origin {
    domain_name              = "${var.project_name}-${var.environment}.${var.zone_name}"    #expense-dev.telugudevops.online
    origin_id                = "${var.project_name}-${var.environment}.${var.zone_name}"
  
  custom_origin_config {
    http_port = 80
    https_port = 443
    origin_protocol_policy = "https-only"
    origin_ssl_protocols = ["TLSv1.2"]  #list of strings

  }
  }

  enabled             = true

  aliases = ["${var.project_name}-${var.common_tags.Component}.${var.zone_name}"]    # expense-cdn.telugudevops.online

#Dynamic content, evaluates at last NoCACHE (Default is a dynamic content)  #Default(*)
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.zone_name}"  #expense-dev.telugudevops.online

    viewer_protocol_policy = "redirect-to-https"  #when user give http, it will redirect to HTTPS 
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    cache_policy_id = data.aws_cloudfront_cache_policy.noCache.id   
  }

  
  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.zone_name}"

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id = data.aws_cloudfront_cache_policy.cacheOptimized.id    #expense-dev.telugudevops.online
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.zone_name}"  #expense-dev.telugudevops.online

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id = data.aws_cloudfront_cache_policy.cacheOptimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "IN"]   #India 
    }
  }

  tags = merge(
    var.common_tags,
    var.cdn_tags,
    {
      Name = local.resource_name  #expense-dev
  }
  )

  viewer_certificate {
    acm_certificate_arn = local.acm_https_cert_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}


#Create RECORDS for Hostpath
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "${var.project_name}-${var.common_tags.Component}"  # expense-cdn
      type    = "A"
      alias = {
        name =  aws_cloudfront_distribution.expense.domain_name #for eg: d604721fxaaqy9.cloudfront.net
        zone_id =  aws_cloudfront_distribution.expense.hosted_zone_id    # This belongs  CloudFront Route 53 zone ID , not ours
      }
      allow_overwrite = true
    }
  ]
}