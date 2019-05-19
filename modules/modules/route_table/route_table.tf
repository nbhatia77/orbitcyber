resource "aws_route_table" "route_table" {
    vpc_id     = "${var.vpc_id}"
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
    }
  tags {
    Name = "${var.route_table_tag}"
  }
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = "${var.subnet1_id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
resource "aws_route_table_association" "subnet2" {
  subnet_id      = "${var.subnet2_id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "subnet3" {
  subnet_id      = "${var.subnet3_id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
