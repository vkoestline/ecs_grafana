variable "prefix" {
  description = "Uniquify resources"
}

variable "password" {
  description = "Grafana Admin Password"
  default = "sasha"
}

variable "lb_security_group_ids" {
  type = "list"
  description = "Security group IDs for load balancer"
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster to attach to"
}

variable "subnet_ids" {
  type = "list"
  description = "Subnet IDs"
}

variable "vpc_id" {
  description = "VPC ID" 
}

variable "domain_name" {
  description = "The Base Domain Name"
}

variable "public_zone_id" {
  description = "The Base Domain Public Zone ID"
}

variable "consul_dns" {
  description = "Consul internal DNS name"
}

variable "db_identifier" {
  description = "Database ID"
  default = "grafanadb"
}

variable "desired_count" {
  description = "Desired Number of Containers To Run"
  default = "8"
}

variable "db_instance_class" {
  description = "Type of DB instance"
  default = "db.t2.micro"
}

variable "db_engine" {
  description = "Type of Database to be used in RDS"
  default = "postgres"
}

variable "db_engine_version" {
  description = "Version of RDS Database Type"
  default = "9.6.6"
}

variable "db_name" {
  description = "Name of the database"
  default = "grafanadb"
}

variable "db_username" {
  description = "Username for the RDS database"
  default = "grafana_admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  default = "grafana_password"
}

variable "db_maintenance_window" {
  description = "When should minor maintenances run on the database"
  default = "Sat:00:05-Sat:02:00"
}

variable "db_backup_window" {
  description = "When should the database be backed up"
  default = "03:00-06:00"
}

variable "db_family" {
  description = "Database family"
  default = "postgres9.6" 
}

variable "grafana_scale_min_capacity" {
  description = "The minimum number of containers"
}

variable "grafana_scale_max_capacity" {
  description = "The maximum number of containers" 
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.46.0.0/16"
}

variable "cloud_account_id" {
  type = "string"
  description = "AWS Account ID"
}

variable "tl_domain" {
  type = "string"
  description = "Top Level Domain Name"
}

variable "common_tags" {
  type = "map"
}

variable "rds_sg" {
  description = "Security group for RDS"
}
