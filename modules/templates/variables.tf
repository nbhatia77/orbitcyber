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

variable "rds_admin_user" {
  type = "string"
}

variable "rds_identifier" {
  description = "DB identifier, such as autodb"
  type = "string"
}

variable "rds_db_name" {
  type = "string"
}

variable "rds_port" {
  type = "string"
}