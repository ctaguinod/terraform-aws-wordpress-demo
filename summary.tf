locals {
  summary = <<SUMMARY

ALB DNS:                  "${aws_alb.alb.dns_name}"
CloudFront Domain:        "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
Bastion host:             ssh ec2-user@${aws_instance.bastion.public_ip}
IP allowed to ssh:        "${local.workstation-external-cidr}"

Wordpress Database Name:  "${var.wp_dbname}"
RDS Database Username:    "${var.rds_username}"
RDS Database Password:    "${random_string.rds_password.result}"
RDS Database Host:        "${aws_db_instance.rds.address}"
MySQL Connection:         mysql -u ${var.rds_username} -p${random_string.rds_password.result} -h ${aws_db_instance.rds.address}

Wordpress:
Site Title:               "${var.wp_title}"
Admin User:               "${var.wp_user}"
Admin Password:           "${var.wp_pass}"
Admin Email:              "${var.wp_email}"

Auto Scaling Group:
min_size:                 "${var.asg_min_size}"
max_size:                 "${var.asg_max_size}"
desired_capacity:         "${var.asg_desired_capacity}"
instance_type:            "${var.instance_type}"

SUMMARY
}

output "summary" {
  value = "${local.summary}"
}
