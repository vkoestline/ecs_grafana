
# --------------------------------------
# Create Application LoadBalancer
# --------------------------------------
resource "aws_alb" "web" {
  name            = "${var.prefix}-grafana-alb"
  internal        = false
  security_groups = ["${var.lb_security_group_ids}"]
  subnets         = ["${var.subnet_ids}"]  

  enable_deletion_protection = false

  tags = "${merge(local.common_tags,map(
      "Name", "${var.prefix}-alb",
  ))}"
}

# --------------------------------------
# Create Target Group
# --------------------------------------
resource "aws_alb_target_group" "web" {
  name     = "${var.prefix}-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/login"
  }

  tags = "${merge(local.common_tags,map(
      "Name", "${var.prefix}-tg-web",
  ))}"

  depends_on = ["aws_alb.web"]
}

# --------------------------------------
# Create ALB Listener
# --------------------------------------
resource "aws_alb_listener" "web_listener" {
   load_balancer_arn = "${aws_alb.web.arn}"
   port = "80"
   protocol = "HTTP"
   default_action {
     target_group_arn = "${aws_alb_target_group.web.arn}"
     type = "forward"
   }

}
