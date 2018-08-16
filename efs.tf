# EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "${random_id.efs_token.hex}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-${var.app}-efs"
  }
}

resource "aws_efs_mount_target" "efs" {
  count           = "${var.vpc_private_subnets_count}"
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(module.vpc.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "random_id" "efs_token" {
  byte_length = 8
  prefix      = "${var.owner}-${var.env}-${var.app}"
}

# EFS Security Group
resource "aws_security_group" "efs-sg" {
  description = "EFS Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    App         = "${var.app}"
    Name        = "${var.owner}-${var.env}-${var.app}-efs-sg"
  }

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.vpc.cidr_block}",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.vpc.cidr_block}",
    ]
  }
}

// Outputs
output "efs_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "efs_dns_name" {
  value = "${aws_efs_file_system.efs.dns_name}"
}
