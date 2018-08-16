# Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
# Examples: https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/v1.37.0/examples

data "aws_availability_zones" "available" {}

data "aws_vpc" "vpc" {
  id = "${module.vpc.vpc_id}"
}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "1.37.0"
  name                   = "${var.owner}-${var.env}-vpc"
  cidr                   = "${var.vpc_cidr}"
  azs                    = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets        = ["${var.vpc_private_subnets1}", "${var.vpc_private_subnets2}", "${var.vpc_private_subnets3}"]
  public_subnets         = ["${var.vpc_public_subnets1}", "${var.vpc_public_subnets2}", "${var.vpc_public_subnets3}"]
  database_subnets       = ["${var.vpc_database_subnets1}", "${var.vpc_database_subnets2}"]
  enable_vpn_gateway     = "${var.vpc_enable_vpn_gateway}"
  enable_nat_gateway     = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway     = "${var.vpc_single_nat_gateway}"
  one_nat_gateway_per_az = "${var.vpc_one_nat_gateway_per_az}"
  enable_dns_hostnames   = true

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-vpc"
  }
}

//output "" {
//  value = "${module.vpc.}"
//}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "private_subnets_cidr_blocks" {
  value = "${module.vpc.private_subnets_cidr_blocks}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "public_subnets_cidr_blocks" {
  value = "${module.vpc.public_subnets_cidr_blocks}"
}

output "vpc_cidr_block" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "database_subnet_group" {
  value = "${module.vpc.database_subnet_group}"
}

output "database_subnets" {
  value = "${module.vpc.database_subnets}"
}

output "database_subnets_cidr_blocks" {
  value = "${module.vpc.database_subnets_cidr_blocks}"
}
