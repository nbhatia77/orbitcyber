variable "project-name" {
  type = "string"
}
variable "env" {
  type = "string"
}

variable "region" {
  description = "AWS Region"
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "security_groups" {
  type = "list"
}


variable "identifier" {
  description = "DB identifier, such as autodb"
  type = "string"
}

variable "instance_class" {
  description = "AWS DB instance, such as db.t2.medium"
  type = "string"
}

variable "allocated_storage" {
  description = "DB storage in days, such as 30"
  type = "string"
}

variable "backup_retention_period" {
  description = "Num. of days to retain backup"
  type = "string"
}

variable "storage_encrypted" {
  description = "Enable DB at rest Encryption - true/false"
  type = "string"
}

variable "storage_type" {
  type = "string"
}

variable "skip_final_snapshot" {
  type = "string"
}

variable "engine" {
  description = "Which RDS DB Engine - postgres/mysql"
  type = "string"
}

variable "engine_version" {
  description = "Which version of DB - For postgress select 9.6.10 and above"
  type = "string"
}

variable "name" {
  description = "Database name, such as airflow_db"
  type = "string"
}

variable "username" {
  description = "DB Admin Username - dbadmin"
  type = "string"
}

variable "publicly_accessible" {
  description = "Make it public accessible - true/false"
  type = "string"
}

variable "multi_az" {
  description = "Configure multi AZ - true/false"
  type = "string"
}

variable "port" {
  description = "RDS Postgres Port - port 3306"
  type = "string"
}

variable "auto_minor_version_upgrade" {
  description = "Allow automated minor version upgrade - true/false"
  type        = "string"
}

variable "final_snapshot_identifier" {
  description = "Name of the final snapshot"
  type = "string"
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM DB Auth - true/false"
  type  = "string"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Enable Cloudwatcg Alerts"
  type  = "list"
}

variable "subnet1_id" {
  type  = "string"
}

variable "subnet2_id" {
  type  = "string"
}
variable "subnet3_id" {
  type  = "string"
}

variable "account_id" {
  type  = "string"
}
