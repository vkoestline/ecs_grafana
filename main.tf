/*
 * This Launches a Grafana Container on the base ECS cluster
*/

# --------------------------------------
# Use locals to reuse common tags for all resources
# --------------------------------------
locals {
  common_tags = "${var.common_tags}"
}

# --------------------------------------
# Read Grafana config JSON file
# --------------------------------------
data "template_file" "grafana_config" {
  template = "${file("${path.module}/grafana.json")}"

  vars {
    grafana_password = "${var.password}"
    grafana_db_name = "${var.db_name}"
    grafana_db_engine = "${var.db_engine}"
    grafana_db_username = "${var.db_username}"
    grafana_db_endpoint = "${module.rds.this_db_instance_endpoint}"
    grafana_db_password = "${var.db_password}"
    grafana_db_port = "${module.rds.this_db_instance_port}"
    grafana_db_host = "${module.rds.this_db_instance_address}"
  }
}

# --------------------------------------
# Create Task Definition
# --------------------------------------
resource "aws_ecs_task_definition" "grafana-task" {
  family                = "grafana-task"
  container_definitions = "${data.template_file.grafana_config.rendered}"
}

# --------------------------------------
# ECS policy
# --------------------------------------
resource "aws_iam_role" "container_service_role" {
  name = "${var.prefix}-ecsServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-ecs-policy" {
  role       = "${aws_iam_role.container_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# --------------------------------------
# Create ECS Service
# --------------------------------------
resource "aws_ecs_service" "grafana-service" {
  name            = "grafana-service"
  cluster         = "${var.ecs_cluster_name}"
  task_definition = "${aws_ecs_task_definition.grafana-task.arn}"
  desired_count   = "${var.desired_count}"

  iam_role = "${aws_iam_role.container_service_role.arn}"
 
  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    container_name = "Grafana-Container"
    container_port = 3000
  }

  provisioner "local-exec" {
    command = "until curl -f -s http://${var.prefix}-grafana.${var.domain_name}.${var.tl_domain}; do sleep 1; done"
  }
}

# --------------------------------------
# Create ECS Service Access Point
# --------------------------------------
#resource "aws_security_group_rule" "allow_grafana" {
#  type        = "ingress"
#  from_port   = 3000
#  to_port     = 3000
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  #security_group_id = "${data.aws_security_group.grafana_security_group.id}" 
#  security_group_id = "${var.security_group_id}"
#}
