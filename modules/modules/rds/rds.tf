# IAM Role and Policy - Global to account
resource "aws_iam_role" "rds_user" {
  name = "rds-user"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "rds_connect" {
  name = "rds_connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "rds-db:connect"
          ],
          "Resource": [
              "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:*/db_user"
          ]
      }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "rds-attach" {
  role       = "${aws_iam_role.rds_user.name}"
  policy_arn = "${aws_iam_policy.rds_connect.arn}"
}

resource "aws_iam_role_policy_attachment" "rds_cloudwatchfullaccess" {
  role       = "${aws_iam_role.rds_user.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy" "ssm_read" {
  name = "ssm_read"
  role = "${aws_iam_role.rds_user.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ssm:DescribeParameters"
      ],
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameters"
        ],
        "Resource": "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.env}/*"
    }
  ]
}
EOF
}

resource "aws_kms_key" "rds_parameter_store" {
  description             = "rds_parameter_store_config_key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Id" : "key-consolepolicy-3",
  "Statement" : [ 
    {
    "Sid" : "Enable IAM User Permissions",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::${var.account_id}:root"
    },
    "Action" : "kms:*",
    "Resource" : "*"
    }, 
    {
    "Sid" : "Allow use of the key",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "${aws_iam_role.rds_user.arn}"
    },
    "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey" ],
    "Resource" : "*"
    }, 
    {
    "Sid" : "Allow attachment of persistent resources",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "${aws_iam_role.rds_user.arn}"
    },
    "Action" : [ "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant" ],
    "Resource" : "*",
    "Condition" : {
      "Bool" : {
        "kms:GrantIsForAWSResource" : "true"
      }
    }
    } 
  ]
}
EOF
}

resource "aws_kms_alias" "rds_config_alias" {
  name          = "alias/rds_config"
  target_key_id = "${aws_kms_key.rds_parameter_store.key_id}"
}

# Generate Secure Password
resource "random_string" "rds_password" {
  length = 15
  special = false
}

# Secure RDS Password
resource "aws_ssm_parameter" "rds_password" {
  name  = "/${var.project-name}-rds-password"
  description  = "${var.project-name}-${var.env}-rds-password"
  type  = "SecureString"
  value = "${random_string.rds_password.result}"
  key_id = "${aws_kms_key.rds_parameter_store.key_id}"

  tags = {
      environmet = "${var.env}"
  }
}

resource "aws_db_subnet_group" "rds-db-subnet" {
  name       = "rds-db-subnet"
  subnet_ids = ["${var.subnet1_id}","${var.subnet2_id}","${var.subnet3_id}"]
}

# RDS SG-limiting in and out-bound traffic
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "RDS Security Group"
  vpc_id = "${var.vpc_id}"
  revoke_rules_on_delete = true

  # Allow inbound traffic from Bastion and Application hosts
  ingress {
    from_port       = "${var.port}"
    to_port         = "${var.port}"
    protocol        = "tcp"
    self            = true
    security_groups = ["${var.security_groups}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "rds_${var.name}_${var.env}_sg"
  }
}

# Build MySql RDS Cluster in multi-az
resource "aws_db_instance" "autodb" {
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  identifier                          = "${var.identifier}"
  instance_class                      = "${var.instance_class}"
  allocated_storage                   = "${var.allocated_storage}"
  storage_encrypted                   = "${var.storage_encrypted}"
  storage_type                        = "${var.storage_type}"
  backup_retention_period             = "${var.backup_retention_period}"
  name                                = "${var.name}"
  username                            = "${var.username}"
  password                            = "${aws_ssm_parameter.rds_password.value}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  multi_az                            = "${var.multi_az}"
  port                                = "${var.port}"
  publicly_accessible                 = "${var.publicly_accessible}"
  auto_minor_version_upgrade          = "${var.auto_minor_version_upgrade}"
  vpc_security_group_ids              = ["${aws_security_group.rds_security_group.id}"]
  db_subnet_group_name                = "${aws_db_subnet_group.rds-db-subnet.name}"
  final_snapshot_identifier           = "${var.final_snapshot_identifier}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  #parameter_group_name                = "${var.name}_${var.engine}_${var.engine_version}"
  enabled_cloudwatch_logs_exports     = "${var.enabled_cloudwatch_logs_exports}"

  tags {
    Name = "${var.project-name}_${var.name}_${var.region}"
  }
}
