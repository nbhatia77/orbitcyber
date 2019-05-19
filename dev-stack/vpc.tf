resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_first_two}.0.0/20"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags {
    Name       = "${var.env}"
    stack_name = "${var.env}"
  }
}

resource "aws_eip" "nat-gw" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat-gw.id}"
  subnet_id     = "${aws_subnet.internet-a.id}"
}

## Ops Security Group ##

resource "aws_security_group" "ops" {
  name        = "${var.env}-ops"
  description = "Allows prodops to SSH"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-ops"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "ops_allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ops.id}"
}

resource "aws_security_group_rule" "ops_allow_all_from_vpn_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.11.0.0/26"]
  security_group_id = "${aws_security_group.ops.id}"
}

## Backhaul ##

resource "aws_route_table" "backhaul" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-backhaul"
    stack_name = "${var.env}"
  }
}

resource "aws_route" "backhaul-nat-gw" {
  route_table_id         = "${aws_route_table.backhaul.id}"
  nat_gateway_id         = "${aws_nat_gateway.nat-gw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "backhaul-a-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.backhaul-a.id}"
  route_table_id = "${aws_route_table.backhaul.id}"
}

resource "aws_subnet" "backhaul-a" {
  availability_zone = "${var.region}b"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.0/27"

  tags {
    Name       = "${var.env}-backhaul-b"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "backhaul-b-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.backhaul-b.id}"
  route_table_id = "${aws_route_table.backhaul.id}"
}

resource "aws_subnet" "backhaul-b" {
  availability_zone = "${var.region}a"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.32/27"

  tags {
    Name       = "${var.env}-backhaul-a"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group" "backhaul" {
  name        = "${var.env}-backhaul"
  description = "Allows application traffic"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-backhaul"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "backhaul_allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.backhaul.id}"
}

resource "aws_security_group_rule" "backhaul_allow_all_from_backhaul_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = "${aws_security_group.backhaul.id}"
}

resource "aws_security_group_rule" "backhaul_allow_all_from_fronthaul_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.fronthaul.id}"
  security_group_id        = "${aws_security_group.backhaul.id}"
}

## Fronthaul ##

resource "aws_route_table" "fronthaul" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-fronthaul"
    stack_name = "${var.env}"
  }
}

resource "aws_route" "fronthaul-nat-gw" {
  route_table_id         = "${aws_route_table.fronthaul.id}"
  nat_gateway_id         = "${aws_nat_gateway.nat-gw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "fronthaul-a" {
  availability_zone = "${var.region}b"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.64/27"

  tags {
    Name       = "${var.env}-fronthaul-b"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "fronthaul-a-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.fronthaul-a.id}"
  route_table_id = "${aws_route_table.fronthaul.id}"
}

resource "aws_subnet" "fronthaul-b" {
  availability_zone = "${var.region}a"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.96/27"

  tags {
    Name       = "${var.env}-fronthaul-a"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "fronthaul-b-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.fronthaul-b.id}"
  route_table_id = "${aws_route_table.fronthaul.id}"
}

resource "aws_security_group" "fronthaul" {
  name        = "${var.env}-fronthaul"
  description = "Allows traffic from fronthaul and backhaul security groups"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-fronthaul"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "fronthaul_allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.fronthaul.id}"
}

resource "aws_security_group_rule" "fronthaul_allow_all_from_backhaul_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = "${aws_security_group.fronthaul.id}"
}

resource "aws_security_group_rule" "fronthaul_allow_all_from_fronthaul_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.backhaul.id}"
  security_group_id        = "${aws_security_group.fronthaul.id}"
}

## Internet ##

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-igw"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-internet"
    stack_name = "${var.env}"
  }
}

resource "aws_route" "internet-igw" {
  route_table_id         = "${aws_route_table.internet.id}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "internet-a" {
  availability_zone = "${var.region}c"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.128/27"

  tags {
    Name       = "${var.env}-internet-c"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "internet-a-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.internet-a.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "internet-b" {
  availability_zone = "${var.region}b"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.160/27"

  tags {
    Name       = "${var.env}-internet-b"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "internet-b-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.internet-b.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "internet-c" {
  availability_zone = "${var.region}a"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.vpc_cidr_first_two}.0.192/27"

  tags {
    Name       = "${var.env}-internet-a"
    stack_name = "${var.env}"
  }
}

resource "aws_route_table_association" "internet-c-subnet-to-routetable" {
  subnet_id      = "${aws_subnet.internet-c.id}"
  route_table_id = "${aws_route_table.internet.id}"
}
