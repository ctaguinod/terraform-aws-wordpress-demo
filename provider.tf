terraform {
  required_version = "= 0.11.7"
}

provider "aws" {
  version    = ">= 1.24.0"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}
