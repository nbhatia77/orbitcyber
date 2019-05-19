output "env" {
  value = "${var.env}"
}

output "key" {
  value = "${var.key_name}"
}

output "vpc" {
  value = "${aws_vpc.main.id}"
}

output "security-group-ops" {
  value = "${aws_security_group.ops.id}"
}

output "security-group-dromsweb" {
  value = "${aws_security_group.dromsweb.id}"
}

output "security-group-dianoga" {
  value = "${aws_security_group.dianoga.id}"
}

output "security-group-ceep-elb" {
  value = "${aws_security_group.ceep_elb.id}"
}

output "ceep-target-group-arn" {
  value = "${aws_alb_target_group.ceep.arn}"
}

output "ceep-autoscale-group-id" {
  value = "${aws_autoscaling_group.ceep.id}"
}

output "subnet-internet-a" {
  value = "${aws_subnet.internet-a.id}"
}

output "subnet-internet-b" {
  value = "${aws_subnet.internet-b.id}"
}

output "subnet-internet-c" {
  value = "${aws_subnet.internet-c.id}"
}

output "private-hosted-zone-id" {
  value = "${aws_route53_zone.private_ag.zone_id}"
}

output "dromsweb-public-cname" {
  value = "${aws_route53_record.dromsweb-public.fqdn}"
}

output "ceep-public-cname" {
  value = "${aws_route53_record.ceep.fqdn}"
}

output "dromsweb-instance-id" {
  value = "${aws_instance.dromsweb_instances.id}"
}