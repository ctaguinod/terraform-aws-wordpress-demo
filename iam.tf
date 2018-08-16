# Wordpress instance profile
resource "aws_iam_instance_profile" "wordpress-instance-profile" {
  name = "${var.owner}-${var.env}-${var.app}-instance-profile"
  role = "${aws_iam_role.wordpress-instance-role.name}"
}

# Wordpress IAM role
resource "aws_iam_role" "wordpress-instance-role" {
  name = "${var.owner}-${var.env}-${var.app}-instance-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "wordpress-instance-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.wordpress-instance-role.name}"
}
