# Common module
provider aws {
  region = "${var.region}"
}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

module "unique_id" {
  source = "./modules/unique_id"
}
# End of common module

# VPC build out with multiple subnets and AZ
module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  vpc_tag              = "rds_vpc_${module.unique_id.unique_id}"
}

module "subnets" {
  source                  = "./modules/subnets"
  vpc_id                  = "${module.vpc.vpc_id}"
  availability_zone_a     = "${data.aws_availability_zones.available.names[0]}"
  availability_zone_b     = "${data.aws_availability_zones.available.names[1]}"
  availability_zone_c     = "${data.aws_availability_zones.available.names[2]}"
  subnet1_cidr_block      = "${var.subnet1_cidr_block}"
  subnet2_cidr_block      = "${var.subnet2_cidr_block}"
  subnet3_cidr_block      = "${var.subnet3_cidr_block}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  subnet1_tag             = "db_az1-subnet${module.unique_id.unique_id}"
  subnet2_tag             = "db_az2-subnet${module.unique_id.unique_id}"
  subnet3_tag             = "db_az3-subnet${module.unique_id.unique_id}"
}

module "route_table" {
  source          = "./modules/route_table"
  vpc_id          = "${module.vpc.vpc_id}"
  igw_id          = "${module.internet_gateway.igw_id}"
  subnet1_id      = "${module.subnets.subnet1_id}"
  subnet2_id      = "${module.subnets.subnet2_id}"
  subnet3_id      = "${module.subnets.subnet3_id}"
  route_table_tag = "${var.project-name}_${var.env}_route_table"
}

module "internet_gateway" {
  source  = "./modules/igw"
  vpc_id  = "${module.vpc.vpc_id}"
  igw_tag = "${var.project-name}_${var.env}_igw"
}
# End of VPC build segment

# RDS MySql module
module "rds" {
  source                              = "./modules/rds"
  region                              = "${var.region}"
  env                                 = "${var.env}"

  account_id                          = "${data.aws_caller_identity.current.account_id}"
  engine                              = "${var.rds_engine}"
  engine_version                      = "${var.rds_engine_version}"
  identifier                          = "${var.rds_identifier}"
  instance_class                      = "${var.rds_instance_type}"
  allocated_storage                   = "${var.rds_storage_size}"
  storage_encrypted                   = "${var.rds_storage_encryption}"
  storage_type                        = "${var.rds_storage_type}"
  backup_retention_period             = "${var.rds_backup_retention}"
  name                                = "${var.rds_db_name}"
  username                            = "${var.rds_admin_user}"
  iam_database_authentication_enabled = "${var.rds_iam_db_auth}"
  multi_az                            = "${var.rds_multi_az}"
  port                                = "${var.rds_port}"
  publicly_accessible                 = "${var.rds_publicly_accessible}"
  auto_minor_version_upgrade          = "${var.rds_auto_minor_version_upgrade}"
  final_snapshot_identifier           = "${var.rds_final_snapshot_identifier}"
  skip_final_snapshot                 = "${var.rds_skip_final_snapshot}"
  enabled_cloudwatch_logs_exports     = "${var.rds_cloudwatch}"
  project-name                        = "${var.project-name}"

  vpc_id                              = "${module.vpc.vpc_id}"
  subnet1_id                          = "${module.subnets.subnet1_id}"
  subnet2_id                          = "${module.subnets.subnet2_id}"
  subnet3_id                          = "${module.subnets.subnet3_id}"

  # For Data Security: Permit Bastion host and application host connection to your RDS only.
  #security_groups                    = "["${data.terraform_remote_state.bastion_state_db.bastion_security_group.id}","${module.app_module.app_sg_id}"]"
  security_groups                     = ["${var.subnet1_cidr_block}","${var.subnet1_cidr_block}","${var.subnet1_cidr_block}"]
}
