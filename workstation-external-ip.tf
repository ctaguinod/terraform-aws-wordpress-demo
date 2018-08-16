#
# Workstation External IP

provider "http" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

output workstation-external-cidr {
  value = "${local.workstation-external-cidr}"
}
