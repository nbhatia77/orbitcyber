resource "aws_subnet" "subnet1" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet1_cidr_block}"
  availability_zone       = "${var.availability_zone_a}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  tags {
        Name = "${var.subnet1_tag}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.subnet2_cidr_block}"
  availability_zone = "${var.availability_zone_b}"
tags {
        Name = "${var.subnet2_tag}"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.subnet3_cidr_block}"
  availability_zone = "${var.availability_zone_c}"
tags {
        Name = "${var.subnet3_tag}"
  }
}