variable "region" {
  default = "us-west-2"
  description = "AWS Region"
}

variable "project-name" {
  type = "string"
  default = "auto-grid"
}

variable "env" {
  type = "string"
  description = "Provide Environment Label"
  default = "dev"
}

variable "vpc_cidr_block" {
  type = "string"
  description = "Autogrid Sandbox VPC ID"
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "AWS instance tenancy in VPC - default/dedicated"
  type = "string"
  default = "default"
}

variable "enable_dns_hostnames" {
  type = "string"
  default = "true"
}

variable "enable_dns_support" {
  type = "string"
  default = "true"
}

variable "subnet1_cidr_block" {
  type  = "string"
  default = "10.0.1.0/24"
}
variable "subnet2_cidr_block" {
  type  = "string"
  default = "10.0.2.0/24"
}
variable "subnet3_cidr_block" {
  type  = "string"
  default = "10.0.3.0/24"
}

variable "map_public_ip_on_launch" {
  description = "Permit mapping pulic IP in subnet - true/false"
  type = "string"
  default = "true"
}

variable "rds_engine" {
  description = "Which RDS DB Engine - postgres/mysql"
  type = "string"
  default = "mysql"
}

variable "rds_engine_version" {
  description = "Which version of DB - For postgress select 9.6.10 and above"
  type = "string"
  default = "8.0.13"
}
variable "rds_identifier" {
  description = "DB identifier, such as psgdb"
  type = "string"
  default = "auto-mysql-db"
}

variable "rds_instance_type" {
  description = "AWS DB instance, such as db.t2.medium"
  type = "string"
  default = "db.t2.medium"
}

variable "rds_storage_size" {
  description = "DB storage in days, such as 30"
  type = "string"
  default = "30"
}

variable "rds_storage_encryption" {
  description = "Enable DB at rest Encryption - true/false"
  type = "string"
  default = "true"
}

variable "rds_storage_type" {
  type = "string"
  default = "gp2"
}

variable "rds_backup_retention" {
  description = "Num. of days to retain backup"
  type = "string"
  default = "7"
}

variable "rds_db_name" {
  description = "Database name, such as airflow_db"
  type = "string"
  default = "auto_mysql_db"
}

variable "rds_admin_user" {
  description = "DB Admin Username - dbadmin"
  type = "string"
  default = "admin"
}

variable "rds_iam_db_auth" {
  description = "Enable IAM DB Auth - true/false"
  type  = "string"
  default = "false"
}

variable "rds_multi_az" {
  description = "Configure multi AZ - true/false"
  type = "string"
  default = "true"
}

variable "rds_port" {
  description = "RDS Postgres Port - type port 3306"
  type = "string"
  default = "3306"
}

variable "rds_publicly_accessible" {
  description = "Make it public accessible - true/false"
  type = "string"
  default = "false"
}

variable "rds_auto_minor_version_upgrade" {
  description = "Allow automated minor version upgrade - true/false"
  type        = "string"
  default     = "true"
}

variable "rds_final_snapshot_identifier" {
  description = "Name of the final snapshot"
  type = "string"
  default = "finalsnapshot"
}

variable "rds_skip_final_snapshot" {
  default = "true"
  type = "string"
}

variable "rds_cloudwatch" {
  description = "Enable Cloudwatcg Alerts"
  type  = "list"
  default = ["error"]
}
