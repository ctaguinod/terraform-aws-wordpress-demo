# Wordpress RDS subnet group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-${var.app}-rds-subnet-group"
  subnet_ids = ["${module.vpc.database_subnets}"]

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-${var.app}-rds-subnet-group"
  }
}

resource "random_string" "rds_password" {
  length  = 10
  special = false
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

# Wordpress RDS
resource "aws_db_instance" "rds" {
  allocated_storage         = "${var.rds_allocated_storage}"
  backup_retention_period   = "${var.rds_backup_retention_period}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds.name}"
  engine                    = "mysql"
  engine_version            = "5.7.19"
  final_snapshot_identifier = "${var.env}${var.app}-final-snap-${random_string.suffix.result}"
  identifier                = "${var.env}${var.app}"
  instance_class            = "${var.db_instance_type}"                                        # note this instance class does not support encryption at rest (would normally encrypt RDS
  multi_az                  = false
  name                      = "${var.env}${var.app}"
  password                  = "${random_string.rds_password.result}"
  storage_encrypted         = false                                                            # see "instance_class"
  storage_type              = "gp2"
  username                  = "${var.rds_username}"
  vpc_security_group_ids    = ["${aws_security_group.rds-sg.id}"]
}

# RDS Security Group
resource "aws_security_group" "rds-sg" {
  description = "RDS Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    App         = "${var.app}"
    Name        = "${var.owner}-${var.env}-${var.app}-rds-sg"
  }

  # Allow MySQL from VPC Subnet CIDRs
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputs
output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}

output "rds_password" {
  value = "${random_string.rds_password.result}"
}
