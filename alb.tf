# ALB
resource "aws_alb" "alb" {
  name            = "${var.owner}-${var.env}-alb"
  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.alb-sg.id}"]

  #access_logs {
  #  bucket = "${var.alb_access_logs_bucket}"
  #  enabled = true
  #}

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-${var.app}-alb"
  }
}

# ALB HTTP Listener
resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.target-group-default.arn}"
    type             = "forward"
  }
}

# Target Group
resource "aws_alb_target_group" "target-group-default" {
  name     = "${var.owner}-${var.env}-target-group-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check {
    path                = "/"
    timeout             = "8"
    interval            = "10"
    unhealthy_threshold = "10"
    healthy_threshold   = "2"
    matcher             = "200-299"
  }

  stickiness {
    type    = "lb_cookie"
    enabled = "false"
  }
}

# ALB Security Group
resource "aws_security_group" "alb-sg" {
  description = "ALB Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-${var.app}-alb-sg"
  }

  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb_dns_name" {
  value = "${aws_alb.alb.dns_name}"
}
