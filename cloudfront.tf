# CLOUDFRONT
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled = "true"
  comment = "${var.owner}-${var.env}-${var.app} CloudFront Distribution"

  #aliases = ["${var.cloudfront_aliases}"]

  # ALB Origin
  origin {
    domain_name = "${aws_alb.alb.dns_name}"
    origin_id   = "${aws_alb.alb.dns_name}"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "http-only"                     #"https-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = "5"
      origin_read_timeout      = "30"
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "${aws_alb.alb.dns_name}"
    viewer_protocol_policy = "allow-all"                                                  #"redirect-to-https"
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 300
    compress               = true

    forwarded_values {
      query_string = "true"
      headers      = ["Host"]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["comment_author_*, comment_author_email_*, comment_author_url_*, wordpress_logged_in_*, wordpress_test_cookie, wp-settings-*"]
      }
    }
  }
  ordered_cache_behavior {
    path_pattern           = "/wp-login.php"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "${aws_alb.alb.dns_name}"
    viewer_protocol_policy = "allow-all"                                                  #"redirect-to-https"
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 300
    compress               = true

    forwarded_values {
      query_string = "true"
      headers      = ["Host"]

      cookies {
        forward = "all" //Fix for Wordpress Dashboard
      }
    }
  }
  ordered_cache_behavior {
    path_pattern           = "/wp-admin/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "${aws_alb.alb.dns_name}"
    viewer_protocol_policy = "allow-all"                                                  #"redirect-to-https"
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 300
    compress               = true

    forwarded_values {
      query_string = "true"
      headers      = ["Host"]

      cookies {
        forward = "all" #Fix for Wordpress Dashboard
      }
    }
  }
  # S3 Bucket Origin
  origin {
    domain_name = "${aws_s3_bucket.s3_bucket_static.bucket_domain_name}"
    origin_id   = "${aws_s3_bucket.s3_bucket_static.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cf-oai.cloudfront_access_identity_path}"
    }
  }
  ordered_cache_behavior {
    path_pattern           = "/wp-content/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${aws_s3_bucket.s3_bucket_static.bucket_domain_name}"
    viewer_protocol_policy = "allow-all"                                            #"redirect-to-https"
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 300
    compress               = true

    forwarded_values {
      query_string = "false"
      headers      = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]

      cookies {
        forward = "none"
      }
    }
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
  }
  viewer_certificate {
    cloudfront_default_certificate = "true"

    #acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

resource "aws_cloudfront_origin_access_identity" "cf-oai" {
  comment = "s3 origin access identity"
}

output "cloudfront_distribution_hosted_zone_id" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id}"
}

output "cloudfront_distribution_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}
