resource "aws_db_instance" "main" {
  allocated_storage    = "${var.db_storage_size_gb}"
  storage_type         = "${var.db_storage_type}"
  engine               = "mysql"
  engine_version       = "${var.db_engine}"
  instance_class       = "${var.db_instance_class}"
  identifier           = "${var.env}-db"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.main.id}"
  parameter_group_name = "${var.db_parameter_group}"
  vpc_security_group_ids = [
    "${aws_security_group.rds.id}"
  ]
  backup_retention_period = 3
  backup_window = "11:27-11:57"
  multi_az = true

  apply_immediately = "${var.db_apply_immediately}" 
  allow_major_version_upgrade = "${var.db_allow_major_version_upgrade}" 
  skip_final_snapshot = true
  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_db_instance" "main-replica" {
  replicate_source_db  = "${aws_db_instance.main.id}"
  instance_class       = "${var.db_replica_instance_class}"
  engine_version       = "${var.db_engine}"
  parameter_group_name = "${var.db_parameter_group}"
  identifier           = "${var.env}-db-replica"
  apply_immediately = "${var.db_apply_immediately}"
  allow_major_version_upgrade = "${var.db_allow_major_version_upgrade}"
  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_db_instance" "ceep" {
  allocated_storage    = "${var.ceep_db_storage_size_gb}"
  storage_type         = "${var.ceep_db_storage_type}"
  engine               = "mysql"
  engine_version       = "${var.ceep_db_engine}"
  instance_class       = "${var.ceep_db_instance_class}"
  identifier           = "${var.env}-db-ceep"
  username             = "${var.ceep_db_username}"
  password             = "${var.ceep_db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.main.id}"
  parameter_group_name = "${var.ceep_db_parameter_group}"
  vpc_security_group_ids = [
    "${aws_security_group.rds.id}"
  ]

  backup_retention_period = 3
  backup_window = "11:27-11:57"
  multi_az = true

  apply_immediately = true

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = [
    "${aws_subnet.backhaul-a.id}",
    "${aws_subnet.backhaul-b.id}",
    "${aws_subnet.fronthaul-a.id}",
    "${aws_subnet.fronthaul-b.id}"
  ]
  tags {
    Name = "${var.env}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds"
  description = "Allows VPN and security group on MySQL port"
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.env}-rds"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "rds_allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.rds.id}"
}

resource "aws_security_group_rule" "rds_allow_3306_from_vpn_ingress" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  cidr_blocks     = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rds.id}"
}

resource "aws_security_group_rule" "rds_allow_3306_from_fronthaul_ingress" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.fronthaul.id}"
  security_group_id = "${aws_security_group.rds.id}"
}

resource "aws_security_group_rule" "rds_allow_3306_from_backhaul_ingress" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.backhaul.id}"
  security_group_id = "${aws_security_group.rds.id}"
}
