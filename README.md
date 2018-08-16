## Wordpress on AWS

Provision Wordpress on AWS using Terraform.

[Reference Architecture / Best Practices](https://aws.amazon.com/blogs/architecture/wordpress-best-practices-on-aws/)

### Requirements:
1. AWS Account.
2. IAM User with Admin privileges.
3. Access and Secret Keys.
4. Terraform installed.

### How to Use:
1. rename `terraform-tfvars-sample` to `terraform.tfvars` and fill in the variables.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. `terraform output summary` - will output all relevant info (resources/endpoint/credentials).
6. `terraform destroy` - will destroy all resources, might need to manually delete s3 bucket if not empty.

### AWS Resources created:
1 x VPC - https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/  
3 x Private Subnets  
3 x Public Subnets  
2 x Database Subnets  
1 x NAT Gateway  
1 x EFS file system (mounted on /var/www/html)  
3 x EFS mount target (1 per AZ)  
1 x RDS MySQL  
1 x ALB  
1 x ASG  
1 x Launch Configuration (AmazonLinux2 AMI)  
1 x EC2 Instance for bastion and Wordpress configuration (AmazonLinux2 AMI)  
1 x IAM role with access to S3 Bucket  
1 x CloudFront distribution  
1 x S3 Bucket for Wordpress static assets  
* Cron Job to sync /var/www/html/wp-content/uploads to S3 bucket  
* Rewrite rule to redirect ^wp-content/uploads/ to CloudFrontDistribution/wp-content/uploads/  

### Next steps:
1. Create AMI from the EC2 instance configured.
2. Update launch configuration to use new AMI and user data.
3. Update ASG min/max/desired instance count and optimise auto scaling policy.
4. Configure NAT gateways for each AZ.
5. Can shutdown bastion host when not in use.
6. Configure HTTPS - need to update ALB and CloudFront.
7. Use own domain with Route53.
8. Enable Logging (ALB / CloudTrail / CloudFront / VPC Flowlogs, etc.).
9. Enable WAF.
10. Configure MultiAZ RDS - update backup/snapshot policy.
11. Setup CloudWatch Dashboard and Alerts.
12. Harden/Optimise OS.
13. Configure Backups.
14. Refactor terraform code and use modules.
