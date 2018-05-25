## --------------------------------------
## RDS Security Group
## --------------------------------------
#resource "aws_security_group" "grafana_rds_sg" {
#  name        = "${var.prefix}-grafana-rds-sg"
#  description = "Allow traffic to pass to port 5432 on RDS from the Grafana dashboard"
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = -1
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    from_port   = "${var.db_port}"
#    to_port     = "${var.db_port}"
#    protocol    = "tcp"
#    cidr_blocks = ["${var.vpc_cidr}"]
#  }
#
#  vpc_id = "${var.vpc_id}"
#
#  tags = "${merge(local.common_tags,map(
#      "Name", "${var.prefix}-grafana_rds_sg",
#  ))}"
#}

# --------------------------------------
# Create Hashicorp Standard RDS 
# --------------------------------------
module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.db_identifier}"

  engine            = "${var.db_engine}"
  engine_version    = "${var.db_engine_version}"
  instance_class    = "${var.db_instance_class}"
 
  # Gigabytes of storage
  allocated_storage = 5

  name     = "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = 5432

  vpc_security_group_ids = ["${var.rds_sg}"]

  maintenance_window = "${var.db_maintenance_window}"
  backup_window      = "${var.db_backup_window}"

  # DB subnet group
  subnet_ids = ["${var.subnet_ids}"]

  # DB parameter group
  family = "${var.db_family}"

  tags = "${merge(local.common_tags,map(
      "Name", "${var.prefix}-GrafanaDB",
  ))}"

}


