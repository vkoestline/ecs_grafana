output "grafana_dns" {
   value = "${aws_alb.web.dns_name}"
}

output "password" {
  value = "${var.password}"
}

output "grafana_db_endpoint" {
  description = "The database  endpoint"
  value       = "${module.rds.this_db_instance_endpoint}"
}
