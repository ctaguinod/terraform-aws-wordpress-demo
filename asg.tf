# ASG
resource "aws_autoscaling_group" "asg" {
  lifecycle {
    create_before_destroy = true
  }

  name                 = "${var.owner}-${var.env}-${var.app}-asg"
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]
  launch_configuration = "${aws_launch_configuration.launch-configuration.id}"
  default_cooldown     = "60"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"
  desired_capacity     = "${var.asg_desired_capacity}"
  health_check_type    = "ELB"
  metrics_granularity  = "1Minute"

  termination_policies = [
    "OldestInstance",
    "ClosestToNextInstanceHour",
  ]

  #enabled_metrics = [
  #  "GroupMinSize",
  #  "GroupMaxSize",
  #  "GroupDesiredCapacity",
  #  "GroupInServiceInstances",
  #  "GroupPendingInstances",
  #  "GroupStandbyInstances",
  #  "GroupTerminatingInstances",
  #  "GroupTotalInstances",
  #]

  target_group_arns = ["${aws_alb_target_group.target-group-default.arn}"]

  //load_balancers    = ["${aws_alb.alb.id}"]

  tags = [
    {
      key                 = "Owner"
      value               = "${var.owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.owner}-${var.env}-${var.app}-asg"
      propagate_at_launch = true
    },
  ]
}

# Launch Configuration
resource "aws_launch_configuration" "launch-configuration" {
  name_prefix                 = "${var.owner}-${var.env}-${var.app}-asg"
  image_id                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.wordpress-instance-profile.name}"
  security_groups             = ["${aws_security_group.ec2-sg.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.wp-asg-user-data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# User Data - Wordpress ASG
data "template_file" "wp-asg-user-data" {
  template = "${file("wp-asg-user-data.sh")}"

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

# Auts Scaling Policy
resource "aws_autoscaling_policy" "asg-policy-scale-up" {
  policy_type               = "StepScaling"
  name                      = "${var.owner}-${var.env}-${var.app}-asg-policy-scale-up"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.asg.name}"
  estimated_instance_warmup = "60"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_autoscaling_policy" "asg-policy-scale-down" {
  policy_type              = "StepScaling"
  name                     = "${var.owner}-${var.env}-${var.app}-asg-policy-scale-down"
  adjustment_type          = "PercentChangeInCapacity"
  autoscaling_group_name   = "${aws_autoscaling_group.asg.name}"
  min_adjustment_magnitude = "1"

  step_adjustment {
    scaling_adjustment          = -25
    metric_interval_upper_bound = 0
  }
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "alarm-cpu-high" {
  alarm_name          = "${var.owner}-${var.env}-${var.app}-alarm-cpu-high"
  alarm_description   = "${var.owner}-${var.env}-${var.app}-alarm-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.asg-policy-scale-up.arn}", "${aws_sns_topic.sns-topic.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "alarm-cpu-low" {
  alarm_name          = "${var.owner}-${var.env}-${var.app}-alarm-cpu-low"
  alarm_description   = "${var.owner}-${var.env}-${var.app}-alarm-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.asg-policy-scale-down.arn}", "${aws_sns_topic.sns-topic.arn}"]
}

resource "aws_autoscaling_notification" "autoscaling-notification" {
  group_names = [
    "${aws_autoscaling_group.asg.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.sns-topic.arn}"
}

# SNS
resource "aws_sns_topic" "sns-topic" {
  name = "${var.owner}-${var.env}-${var.app}-sns"
}

# EC2 Instance Security Group
resource "aws_security_group" "ec2-sg" {
  description = "EC2 Instance Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    App         = "${var.app}"
    Name        = "${var.owner}-${var.env}-${var.app}-ec2-sg"
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
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-sg.id}"]
  }

  #ingress {
  #  from_port       = 443
  #  to_port         = 443
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}
}
