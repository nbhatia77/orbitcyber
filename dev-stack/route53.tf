resource "aws_route53_zone" "private_ag" {
  name = "autogrid.aws"
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "autogrid.aws"
    stack_name = "${var.env}"
  }
}

# RDS
resource "aws_route53_record" "rds-main" {
  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.rds"
  type = "CNAME"
  records = ["${aws_db_instance.main.address}"] }

resource "aws_route53_record" "rds-main-replica" {
  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.rds-replica"
  type = "CNAME"
  records = ["${aws_db_instance.main-replica.address}"]
}

resource "aws_route53_record" "rds-ceep" {
  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.rds-ceep"
  type = "CNAME"
  records = ["${aws_db_instance.ceep.address}"]
}

# EC2
resource "aws_route53_record" "dromsweb" {
  count = "${var.n_droms_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("dromsweb%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.dromsweb_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "dromsweb-public" {
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-${format("dromsweb%02d", count.index + 1)}"
  type = "A"
  records = [
    "${var.droms_subnet_placement == "public" ? element(aws_instance.dromsweb_instances.*.public_ip, count.index) : element(aws_instance.dromsweb_instances.*.private_ip, count.index)}"
  ]
}

resource "aws_route53_record" "dromsweb-mx" {
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-${format("dromsweb%02d", count.index + 1)}"
  type = "MX"
  records = ["1 mx.sendgrid.net"]
}

resource "aws_route53_record" "sms-opt-out" {
  count = "${var.n_proxy_instances}"

  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-sms-opt-out.autogridsystems.net"
  type = "CNAME"
  records = ["${var.env}-proxy01.autogridsystems.net"]
}

resource "aws_route53_record" "emailwebhook" {
  count = "${var.n_proxy_instances}"

  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-emailwebhook.autogridsystems.net"
  type = "CNAME"
  records = ["${var.env}-proxy01.autogridsystems.net"]
}

resource "aws_route53_record" "ceep" {
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-ceep.autogridsystems.net"
  type = "CNAME"
  records = ["${aws_alb.ceep.dns_name}"]
}

resource "aws_route53_record" "pheme" {
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-pheme.autogridsystems.net"
  type = "CNAME"
  records = ["${aws_alb.pheme.dns_name}"]
}

resource "aws_route53_record" "redis" {
  count = "${var.n_redis_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("redis%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.redis_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "dianoga" {
  count = "${var.n_dianoga_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("dianoga%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.dianoga_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "dianoga_public" {
  count = "${var.n_dianoga_instances}"

  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-dianoga-sftp.autogridsystems.net"
  type = "A"
  records = [
    "${var.dianoga_subnet_placement == "public" ? element(aws_instance.dianoga_instances.*.public_ip, count.index) : element(aws_instance.dianoga_instances.*.private_ip, count.index)}"
  ]
}


resource "aws_route53_record" "rtcc" {
  count = "${var.n_rtcc_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("rtcc%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.rtcc_instances.*.private_ip, count.index)}"]
}


resource "aws_route53_record" "rabbitmq" {
  count = "${var.n_rabbitmq_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("rabbitmq%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.rabbitmq_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "hbase-master" {
  count = "${var.n_hbase-master_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("hbase-master%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.hbase-master_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "fam-listener" {
  count = "${var.n_fam-listener_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("fam-listener%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.fam-listener_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "faas-listener" {
  count = "${var.n_faas-listener_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("faas-listener%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.faas-listener_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "tusker" {
  count = "${var.n_tusker_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("tusker%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.tusker_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "cascade" {
  count = "${var.n_cascade_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("cascade%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.cascade_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "cascade-public" {
  count = "${var.n_cascade_instances}"

  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-${format("cascade%02d", count.index + 1)}"
  type = "A"
  records = [
    "${var.cascade_subnet_placement == "public" ? element(aws_instance.cascade_instances.*.public_ip, count.index) : element(aws_instance.cascade_instances.*.private_ip, count.index)}"
  ]
}

resource "aws_route53_record" "analytics-server" {
  count = "${var.n_analytics-server_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("analytics-server%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.analytics-server_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "proxy" {
  count = "${var.n_proxy_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("proxy%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.proxy_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "proxy-public" {
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-${format("proxy%02d", count.index + 1)}"
  type = "A"
  #records = ["${element(aws_instance.proxy_instances.*.private_ip, count.index)}"]
  records = ["${element(aws_eip.proxy.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "openadr2b" {
  count = "${var.n_openadr2b_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("openadr2b%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.openadr2b_instances.*.private_ip, count.index)}"]
}
resource "aws_route53_record" "openadr2b-public" {
  count = "${var.n_openadr2b_instances}"

  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-${format("openadr2b%02d", count.index + 1)}"
  type = "A"
  records = [
    "${var.openadr2b_subnet_placement == "public" ? element(aws_instance.openadr2b_instances.*.public_ip, count.index) : element(aws_instance.openadr2b_instances.*.private_ip, count.index)}"
  ]
}

resource "aws_route53_record" "grafana" {
  count = "${var.n_grafana_instances}"

  ttl = 300
  zone_id = "${aws_route53_zone.private_ag.zone_id}"
  name = "${var.env}.${format("grafana%02d.autogrid.aws", count.index + 1)}"
  type = "CNAME"
  records = ["${element(aws_instance.grafana_instances.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "grafana-public" {
  count           = "${var.n_grafana_instances == 0 ? 0 : 1}"
  ttl = 300
  zone_id = "Z1J5080J3E9QPW" # Public autogridsystems.net zone
  name = "${var.env}-grafana.autogridsystems.net"
  type = "CNAME"
  records = ["${aws_alb.grafana.dns_name}"]
}
