# S3 bucket for wordpress static files
resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = "${var.owner}-${var.env}-${var.app}-static"
  acl           = "public-read"
  force_destroy = false

  #cors_rule {
  #  allowed_origins = ["${aws_alb.alb.dns_name}"]
  #  allowed_methods = ["GET", "HEAD"]
  #  max_age_seconds = 3000
  #  allowed_headers = ["Authorization"]
  #}

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-${var.app}-static"
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "Policy1410256987704",
  "Statement": [
    {
      "Sid": "Stmt1410256977473",
      "Effect": "Allow",
      "Principal": {
          "AWS": "*"
          },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.owner}-${var.env}-${var.app}-static/*"
    }
  ]
}
EOF
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
