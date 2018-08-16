# Bastion Instance - used to configure Wordpress, files to be stored in EFS
resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.wordpress-instance-profile.name}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  user_data                   = "${data.template_file.wp-bastion-user-data.rendered}"
  associate_public_ip_address = true
  count                       = 1

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-bastion"
    Role        = "Bastion Host/Provison Wordpress"
    sshUser     = "ec2-user"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }

  # Wait for EFS to be provisioned
  depends_on = ["aws_efs_file_system.efs", "aws_efs_mount_target.efs", "aws_db_instance.rds", "aws_alb.alb"]
}

# Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.owner}_key_pair"
  public_key = "${data.template_file.ssh_public_key.rendered}"
}

# SSH Public Key
data "template_file" "ssh_public_key" {
  template = "${file("~/.ssh/id_rsa.pub")}"
}

# User Data - Bastion Host / Wordpress Config
data "template_file" "wp-bastion-user-data" {
  template = "${file("wp-bastion-user-data.sh")}"

  vars {
    efs_dns_name                        = "${aws_efs_file_system.efs.dns_name}"
    alb_dns_name                        = "${aws_alb.alb.dns_name}"
    cloudfront_distribution_domain_name = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
    s3_bucket_static_name               = "${aws_s3_bucket.s3_bucket_static.id}"
    DB_NAME                             = "${var.wp_dbname}"
    DB_USER                             = "${var.rds_username}"
    DB_PASSWORD                         = "${random_string.rds_password.result}"
    DB_HOST                             = "${aws_db_instance.rds.address}"
    WP_TITLE                            = "${var.wp_title}"
    WP_USER                             = "${var.wp_user}"
    WP_PASS                             = "${var.wp_pass}"
    WP_EMAIL                            = "${var.wp_email}"
  }
}

# EC2 Instance Security Group
resource "aws_security_group" "bastion-sg" {
  description = "EC2 Instance Bastion Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    App         = "${var.app}"
    Name        = "${var.owner}-${var.env}-${var.app}-bastion-sg"
  }

  # Allow SSH Traffic from workstation IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.workstation-external-cidr}"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from same Security Group
  #ingress {
  #  from_port = 0
  #  to_port   = 0
  #  protocol  = "-1"
  #  self      = "true"
  #}

  // Allow HTTP/HTTPS from ALB
  #ingress {
  #  from_port       = 80
  #  to_port         = 80
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}

  #ingress {
  #  from_port       = 443
  #  to_port         = 443
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}
}

// Outputs
output "bastion_private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "bastion_id" {
  value = "${aws_instance.bastion.id}"
}
