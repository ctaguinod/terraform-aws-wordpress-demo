# Variables

# Provider
variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  default = "us-east-1"
  type    = "string"
}

# Tags
variable "env" {
  default = "demo"
  type    = "string"
}

variable "owner" {
  default = "owner"
  type    = "string"
}

variable "app" {
  default = "app"
  type    = "string"
}

# VPC
variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type    = "string"
}

variable "vpc_private_subnets1" {
  default = "10.0.1.0/24"
  type    = "string"
}

variable "vpc_private_subnets2" {
  default = "10.0.2.0/24"
  type    = "string"
}

variable "vpc_private_subnets3" {
  default = "10.0.3.0/24"
  type    = "string"
}

# Workaround for EFS, define number of subnets
variable "vpc_private_subnets_count" {
  default = "3"
  type    = "string"
}

variable "vpc_database_subnets1" {
  default = "10.0.21.0/24"
  type    = "string"
}

variable "vpc_database_subnets2" {
  default = "10.0.22.0/24"
  type    = "string"
}

variable "vpc_public_subnets1" {
  default = "10.0.101.0/24"
  type    = "string"
}

variable "vpc_public_subnets2" {
  default = "10.0.102.0/24"
  type    = "string"
}

variable "vpc_public_subnets3" {
  default = "10.0.103.0/24"
  type    = "string"
}

variable "vpc_enable_nat_gateway" {
  default = "false"
  type    = "string"
}

variable "vpc_enable_vpn_gateway" {
  default = "false"
  type    = "string"
}

variable "vpc_single_nat_gateway" {
  default = "false"
  type    = "string"
}

variable "vpc_one_nat_gateway_per_az" {
  default = "false"
  type    = "string"
}

# ASG
variable "asg_desired_capacity" {
  default = "1"
  type    = "string"
}

variable "asg_max_size" {
  default = "1"
  type    = "string"
}

variable "asg_min_size" {
  default = "1"
  type    = "string"
}

variable "instance_type" {
  default = "t2.micro"
  type    = "string"
}

# RDS
variable "db_instance_type" {
  default = "db.t2.micro"
  type    = "string"
}

variable "rds_username" {
  default = "dbadmin"
  type    = "string"
}

variable "rds_allocated_storage" {
  default = "5"
  type    = "string"
}

variable "rds_backup_retention_period" {
  default = "7"
  type    = "string"
}

# WORDPRESS
variable "wp_title" {
  default = "Hello Wordpress"
  type    = "string"
}

variable "wp_user" {
  default = "wpadmin"
  type    = "string"
}

variable "wp_pass" {
  default = "hellowordpress"
  type    = "string"
}

variable "wp_email" {
  type = "string"
}

variable "wp_dbname" {
  default = "wordpress"
  type    = "string"
}
