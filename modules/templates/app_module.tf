#  *** THIS IS A BASELINE TEMPLATE ***
#  --> PLEASE COPY AND THEN MODIFY <--

# NOTE: Please call this module from main module file by passing linked variables.

# *** This is required configuration module for any
#   application connecting to RDS MySql DB ***

# This is how temp DB Admin password is over-written by the application

data "template_file" "supplement_script" {
    template = "${file("${path.module}/templates/supplement_script.tpl")}"
    vars {
        env                     = "${var.env}"
        region                  = "${var.region}"
        app_mysql_db_identifier = "${var.rds_identifier}"
        app_mysql_db_username   = "${var.rds_admin_user}"
        app_mysql_db_port       = "${var.rds_port}"
        app_mysql_db_name       = "${var.rds_db_name}"
        # Pass other options: Ansible playbook or rpm
        # ansible_playbook_rpm  = "${var.ansible_playbook_rpm}"
    }
}

data "terraform_remote_state" "bastion_state_db" {
    # This is your bastion host config
    #           OR
    # Use Outputs.tf to get Bastion host data
}

resource "aws_security_group" "app_security_group" {
  name        = "app_security_group"
  description = "<YOUR APPLICATION> Security Group"
  vpc_id = "${var.vpc_id}"

  # Allow inboundd traffic from Bastion and Application hosts
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    self        = true
    security_groups = ["${data.terraform_remote_state.bastion_state_db.bastion_security_group.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.subnet1_cidr_block}","${var.subnet2_cidr_block}","${var.subnet3_cidr_block}"]
  }
  tags {
    Name = "<YOUR APPLICATION>_security_group"
  }
}

resource "aws_iam_role" "application_iam_role" {
  name = "<YOUR APPLICATION>_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_polcy" "iam_app_modifydbinstance_policy" {
    name = "<YOUR APPLICATION>_modifydbinstance_policy"

    policy = <<EOF

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:ModifyDBInstance"
            ],
            "Resource": [
                "arn:aws:rds:${var.region}:*:secgrp:db:test*",
                "arn:aws:rds:${var.region}:*:og:default*",
                "arn:aws:rds:${var.region}:*:pg:default*",
                "arn:aws:rds:${var.region}:*:db:default"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app_extra_policy_attachment" {
    role        = "${aws_iam_role.application_iam_role.name}"
    policy_arn  = "${aws_iam_polcy.iam_app_modifydbinstance_policy.arn}"
}
