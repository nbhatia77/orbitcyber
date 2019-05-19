resource "aws_instance" "dromsweb_instances" {
  count = "${var.n_droms_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.droms_instance_type}"
  subnet_id     = "${var.droms_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.fronthaul-a.id}"
  ebs_optimized = "${var.droms_ebs_optimization}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.dromsweb.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.droms_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "subnet_id"]
  }

  tags {
    Name       = "${var.env}.${format("dromsweb%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "dromsweb"
  }
}

resource "aws_eip" "dromsweb" {
  count    = "${var.droms_subnet_placement == "public" ? var.n_droms_instances : 0}"
  instance = "${aws_instance.dromsweb_instances.*.id[count.index]}"
  vpc      = true
}

resource "aws_security_group" "dromsweb" {
  name        = "${var.env}-dromsweb"
  description = "Allows traffic from HTTP and HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-dromsweb"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "dromsweb_allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.dromsweb.id}"
}

resource "aws_security_group_rule" "dromsweb_allow_HTTP_from_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.dromsweb.id}"
}

resource "aws_security_group_rule" "dromsweb_allow_HTTPS_from_vpn" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.dromsweb.id}"
}

resource "aws_ebs_volume" "dromsweb" {
  count             = "${var.n_droms_instances}"
  availability_zone = "${aws_instance.dromsweb_instances.*.availability_zone[count.index]}"
  size              = "${var.droms_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "dromsweb" {
  count        = "${var.n_droms_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.dromsweb.*.id[count.index]}"
  instance_id  = "${aws_instance.dromsweb_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_alb" "ceep" {
  count           = "${var.n_ceep_instances == 0 ? 0 : 1}"
  name            = "${var.env}-ceep"
  internal        = false
  security_groups = ["${aws_security_group.ceep_elb.id}"]

  subnets = [
    "${aws_subnet.internet-a.id}",
    "${aws_subnet.internet-b.id}",
    "${aws_subnet.internet-c.id}",
  ]

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_alb_listener" "ceep" {
  count             = "${var.n_ceep_instances == 0 ? 0 : 1}"
  load_balancer_arn = "${aws_alb.ceep.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.external_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ceep.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "ceep-http" {
  count             = "${var.n_ceep_instances == 0 ? 0 : 1}"
  load_balancer_arn = "${aws_alb.ceep.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ceep.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "ceep" {
  count    = "${var.n_ceep_instances == 0 ? 0 : 1}"
  name     = "${var.env}-ceep-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  health_check {
    path    = "/api/v1/health/pulse"
    matcher = 200
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_ceep" {
  count                  = "${var.n_ceep_instances == 0 ? 0 : 1}"
  autoscaling_group_name = "${aws_autoscaling_group.ceep.id}"
  alb_target_group_arn   = "${aws_alb_target_group.ceep.arn}"
}

resource "aws_security_group" "ceep_elb" {
  count       = "${var.n_ceep_instances == 0 ? 0 : 1}"
  name        = "${var.env}-ceep_elb"
  description = "Allows all to HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-ceep_elb"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "ceep_elb_allow_all_egress" {
  count             = "${var.n_ceep_instances == 0 ? 0 : 1}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ceep_elb.id}"
}

resource "aws_security_group_rule" "ceep_elb_allow_https_from_all" {
  count             = "${var.n_ceep_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ceep_elb.id}"
}

resource "aws_security_group_rule" "ceep_elb_allow_http_from_all" {
  count             = "${var.n_ceep_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ceep_elb.id}"
}

resource "aws_security_group" "ceep" {
  count       = "${var.n_ceep_instances == 0 ? 0 : 1}"
  name        = "${var.env}-ceep"
  description = "Allows ceep ELB to HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-ceep"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "ceep_allow_http_from_elb" {
  count                    = "${var.n_ceep_instances == 0 ? 0 : 1}"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.ceep_elb.id}"
  security_group_id        = "${aws_security_group.ceep.id}"
}

resource "aws_launch_configuration" "ceep" {
  count         = "${var.n_ceep_instances == 0 ? 0 : 1}"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.ceep_instance_type}"

  security_groups = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.ceep.id}",
  ]

  key_name = "${var.key_name}"

  root_block_device {
    volume_size = "${var.ceep_root_volume_size}"
    volume_type = "gp2"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "${var.ceep_ag_volume_size}"
  }

  lifecycle {
    ignore_changes = ["image_id", "root_block_device"]
  }
}

resource "aws_autoscaling_group" "ceep" {
  count                = "${var.n_ceep_instances == 0 ? 0 : 1}"
  name                 = "${var.env}-ceep-tf"
  launch_configuration = "${aws_launch_configuration.ceep.name}"

  vpc_zone_identifier = [
    "${aws_subnet.fronthaul-a.id}",
    "${aws_subnet.fronthaul-b.id}",
  ]

  min_size              = "${var.n_ceep_instances}"
  max_size              = "${var.n_ceep_instances}"
  protect_from_scale_in = true

  suspended_processes = [
    "ReplaceUnhealthy",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.env}.ceep.autogrid.aws"
      propagate_at_launch = true
    },
    {
      key                 = "backup"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "stack_name"
      value               = "${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "ceep"
      propagate_at_launch = true
    },
  ]
}

resource "aws_alb" "pheme" {
  count           = "${var.n_pheme_instances == 0 ? 0 : 1}"
  name            = "${var.env}-pheme"
  internal        = false
  security_groups = ["${aws_security_group.pheme_elb.id}"]

  subnets = [
    "${aws_subnet.internet-a.id}",
    "${aws_subnet.internet-b.id}",
    "${aws_subnet.internet-c.id}",
  ]

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_alb_listener" "pheme" {
  count             = "${var.n_pheme_instances == 0 ? 0 : 1}"
  load_balancer_arn = "${aws_alb.pheme.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.external_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.pheme.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "pheme" {
  count    = "${var.n_pheme_instances == 0 ? 0 : 1}"
  name     = "${var.env}-pheme-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  health_check {
    protocol = "HTTP"
    path     = "/"
    matcher  = 200
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_pheme" {
  count                  = "${var.n_pheme_instances == 0 ? 0 : 1}"
  autoscaling_group_name = "${aws_autoscaling_group.pheme.id}"
  alb_target_group_arn   = "${aws_alb_target_group.pheme.arn}"
}

resource "aws_security_group" "pheme_elb" {
  count       = "${var.n_pheme_instances == 0 ? 0 : 1}"
  name        = "${var.env}-pheme_elb"
  description = "Allows all to HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-pheme_elb"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "pheme_elb_allow_all_egress" {
  count             = "${var.n_pheme_instances == 0 ? 0 : 1}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.pheme_elb.id}"
}

resource "aws_security_group_rule" "pheme_elb_allow_https_from_all" {
  count             = "${var.n_pheme_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.pheme_elb.id}"
}

resource "aws_security_group" "pheme" {
  count       = "${var.n_pheme_instances == 0 ? 0 : 1}"
  name        = "${var.env}-pheme"
  description = "Allows pheme ELB to HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-pheme"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "pheme_allow_https_from_elb" {
  count                    = "${var.n_pheme_instances == 0 ? 0 : 1}"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.pheme_elb.id}"
  security_group_id        = "${aws_security_group.pheme.id}"
}

resource "aws_launch_configuration" "pheme" {
  count         = "${var.n_pheme_instances == 0 ? 0 : 1}"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.pheme_instance_type}"

  security_groups = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.pheme.id}",
  ]

  key_name = "${var.key_name}"

  root_block_device {
    volume_size = "${var.pheme_root_volume_size}"
    volume_type = "gp2"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "${var.pheme_ag_volume_size}"
  }

  lifecycle {
    ignore_changes = ["image_id", "root_block_device"]
  }
}

resource "aws_autoscaling_group" "pheme" {
  count                = "${var.n_pheme_instances == 0 ? 0 : 1}"
  name                 = "${var.env}-pheme-tf"
  launch_configuration = "${aws_launch_configuration.pheme.name}"

  vpc_zone_identifier = [
    "${aws_subnet.fronthaul-a.id}",
    "${aws_subnet.fronthaul-b.id}",
  ]

  min_size              = "${var.n_pheme_instances}"
  max_size              = "${var.n_pheme_instances}"
  protect_from_scale_in = true

  suspended_processes = [
    "ReplaceUnhealthy",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.env}.pheme.autogrid.aws"
      propagate_at_launch = true
    },
    {
      key                 = "backup"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "stack_name"
      value               = "${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "pheme"
      propagate_at_launch = true
    },
  ]
}

resource "aws_security_group" "redis" {
  name        = "${var.env}-redis"
  description = "Allows redis ports from VPN"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-ceep"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "redis_allow_6379_from_vpn" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.redis.id}"
}

resource "aws_instance" "redis_instances" {
  count = "${var.n_redis_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.redis_instance_type}"
  subnet_id     = "${var.redis_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.redis.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.redis_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("redis%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "redis"
  }
}

resource "aws_ebs_volume" "redis" {
  count             = "${var.n_redis_instances}"
  availability_zone = "${aws_instance.redis_instances.*.availability_zone[count.index]}"
  size              = "${var.redis_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "redis" {
  count        = "${var.n_redis_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.redis.*.id[count.index]}"
  instance_id  = "${aws_instance.redis_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_instance" "dianoga_instances" {
  count = "${var.n_dianoga_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.dianoga_instance_type}"
  subnet_id     = "${var.dianoga_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.fronthaul-b.id}"
  ebs_optimized = "${var.dianoga_ebs_optimization}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.dianoga.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.dianoga_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "id"]
  }

  tags {
    Name       = "${var.env}.${format("dianoga%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "dianoga"
  }
}

resource "aws_eip" "dianoga" {
  count    = "${var.dianoga_subnet_placement == "public" ? var.n_dianoga_instances : 0}"
  instance = "${aws_instance.dianoga_instances.*.id[count.index]}"
  vpc      = true
}

resource "aws_ebs_volume" "dianoga" {
  count             = "${var.n_dianoga_instances}"
  availability_zone = "${aws_instance.dianoga_instances.*.availability_zone[count.index]}"
  size              = "${var.dianoga_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "dianoga" {
  count        = "${var.n_dianoga_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.dianoga.*.id[count.index]}"
  instance_id  = "${aws_instance.dianoga_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_ebs_volume" "dianoga_sftp" {
  count             = "${var.n_dianoga_instances}"
  availability_zone = "${aws_instance.dianoga_instances.*.availability_zone[count.index]}"
  size              = "${var.dianoga_sftp_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "dianoga_sftp" {
  count        = "${var.n_dianoga_instances}"
  device_name  = "/dev/sdg"
  volume_id    = "${aws_ebs_volume.dianoga_sftp.*.id[count.index]}"
  instance_id  = "${aws_instance.dianoga_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "dianoga" {
  name        = "${var.env}-dianoga"
  description = "Allows SSH traffic from internet"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-dianoga"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "dianoga_allow_22_from_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.dianoga.id}"
}

resource "aws_instance" "edp-ps_instances" {
  count = "${var.n_edp-ps_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.edp-ps_instance_type}"
  subnet_id     = "${var.edp-ps_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.backhaul-b.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.edp-ps_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("edp-ps.autogrid.aws")}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "edp-ps"
  }
}

resource "aws_ebs_volume" "edp-ps" {
  count             = "${var.n_edp-ps_instances}"
  availability_zone = "${aws_instance.edp-ps_instances.*.availability_zone[count.index]}"
  size              = "${var.edp-ps_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "edp-ps" {
  count        = "${var.n_edp-ps_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.edp-ps.*.id[count.index]}"
  instance_id  = "${aws_instance.edp-ps_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "rtcc" {
  name        = "${var.env}-rtcc"
  description = "Allows traffic from RTCC app prots"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-rtcc"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "rtcc_allow_80_from_VPN" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rtcc.id}"
}

resource "aws_security_group_rule" "rtcc_allow_443_from_VPN" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rtcc.id}"
}

resource "aws_security_group_rule" "rtcc_allow_9000_from_VPN" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rtcc.id}"
}

resource "aws_instance" "rtcc_instances" {
  count = "${var.n_rtcc_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.rtcc_instance_type}"
  subnet_id     = "${var.rtcc_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.fronthaul-b.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.rtcc.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.rtcc_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("rtcc%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "rtcc"
  }
}

resource "aws_ebs_volume" "rtcc" {
  count             = "${var.n_rtcc_instances}"
  availability_zone = "${aws_instance.rtcc_instances.*.availability_zone[count.index]}"
  size              = "${var.rtcc_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "rtcc" {
  count        = "${var.n_rtcc_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.rtcc.*.id[count.index]}"
  instance_id  = "${aws_instance.rtcc_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "rabbitmq" {
  name        = "${var.env}-rabbitmq"
  description = "Allows VPN traffic to rabbitmq managment ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-rabbitmq"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "rabbitmq_allow_15672_from_VPN" {
  type              = "ingress"
  from_port         = 15672
  to_port           = 15672
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rabbitmq.id}"
}

resource "aws_security_group_rule" "rabbitmq_allow_5672_from_VPN" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.rabbitmq.id}"
}

resource "aws_instance" "rabbitmq_instances" {
  count = "${var.n_rabbitmq_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.rabbitmq_instance_type}"
  subnet_id     = "${var.rabbitmq_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.backhaul-b.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.rabbitmq.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.rabbitmq_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("rabbitmq%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "rabbitmq"
  }
}

resource "aws_ebs_volume" "rabbitmq" {
  count             = "${var.n_rabbitmq_instances}"
  availability_zone = "${aws_instance.rabbitmq_instances.*.availability_zone[count.index]}"
  size              = "${var.rabbitmq_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "rabbitmq" {
  count        = "${var.n_rabbitmq_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.rabbitmq.*.id[count.index]}"
  instance_id  = "${aws_instance.rabbitmq_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "hbase-master" {
  name        = "${var.env}-hbase-master"
  description = "Allows traffic VPN traffic to cdh ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-hbase-master"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "hbase-master_allow_7180_from_VPN" {
  type              = "ingress"
  from_port         = 7180
  to_port           = 7180
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.hbase-master.id}"
}

resource "aws_security_group_rule" "hbase-master_allow_8888_from_VPN" {
  type              = "ingress"
  from_port         = 8888
  to_port           = 8888
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.hbase-master.id}"
}

resource "aws_security_group_rule" "hbase-master_allow_8088_from_VPN" {
  type              = "ingress"
  from_port         = 8088
  to_port           = 8088
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.hbase-master.id}"
}

resource "aws_security_group_rule" "hbase-master_allow_19888_from_VPN" {
  type              = "ingress"
  from_port         = 19888
  to_port           = 19888
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.hbase-master.id}"
}

resource "aws_instance" "hbase-master_instances" {
  count = "${var.n_hbase-master_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.hbase-master_instance_type}"
  subnet_id     = "${var.hbase-master_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  ebs_optimized = "${var.hbase-master_ebs_optimization}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.hbase-master.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.hbase-master_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "id", "root_block_device"]
  }

  tags {
    Name       = "${var.env}.${format("hbase-master%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "hbase-master,hbase-all,faas-master,faas"
  }
}

resource "aws_ebs_volume" "hbase-master" {
  count             = "${var.n_hbase-master_instances}"
  availability_zone = "${aws_instance.hbase-master_instances.*.availability_zone[count.index]}"
  size              = "${var.hbase-master_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "hbase-master" {
  count        = "${var.n_hbase-master_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.hbase-master.*.id[count.index]}"
  instance_id  = "${aws_instance.hbase-master_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_ebs_volume" "hbase-master_hbase" {
  count             = "${var.n_hbase-master_instances}"
  availability_zone = "${aws_instance.hbase-master_instances.*.availability_zone[count.index]}"
  size              = "${var.hbase-master_hbase_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "hbase-master_hbase" {
  count        = "${var.n_hbase-master_instances}"
  device_name  = "/dev/sdg"
  volume_id    = "${aws_ebs_volume.hbase-master_hbase.*.id[count.index]}"
  instance_id  = "${aws_instance.hbase-master_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_instance" "hbase-worker_instances" {
  count = "${var.n_hbase-worker_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.hbase-worker_instance_type}"
  subnet_id     = "${var.flip_workers == false ? (count.index + 1) % 2 == 0 ? aws_subnet.backhaul-b.id : aws_subnet.backhaul-a.id : (count.index + 1) % 2 == 0 ? aws_subnet.backhaul-a.id : aws_subnet.backhaul-b.id}"
  ebs_optimized = "${var.hbase-worker_ebs_optimization}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.hbase-worker_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "id", "root_block_device"]
  }

  tags {
    Name       = "${var.env}.${format("hbase-worker%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "hbase-worker,hbase-workers,hbase-all,faas-workers,faas"
  }
}

resource "aws_ebs_volume" "hbase-worker" {
  count             = "${var.n_hbase-worker_instances}"
  availability_zone = "${aws_instance.hbase-worker_instances.*.availability_zone[count.index]}"
  size              = "${var.hbase-worker_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "hbase-worker" {
  count        = "${var.n_hbase-worker_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.hbase-worker.*.id[count.index]}"
  instance_id  = "${aws_instance.hbase-worker_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_ebs_volume" "hbase-worker_hbase" {
  count             = "${var.n_hbase-worker_instances}"
  availability_zone = "${aws_instance.hbase-worker_instances.*.availability_zone[count.index]}"
  size              = "${var.hbase-worker_hbase_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "hbase-worker_hbase" {
  count        = "${var.n_hbase-worker_instances}"
  device_name  = "/dev/sdg"
  volume_id    = "${aws_ebs_volume.hbase-worker_hbase.*.id[count.index]}"
  instance_id  = "${aws_instance.hbase-worker_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_ebs_volume" "hbase-worker_kafka" {
  count             = "${var.n_hbase-worker_instances}"
  availability_zone = "${aws_instance.hbase-worker_instances.*.availability_zone[count.index]}"
  size              = "${var.hbase-worker_kafka_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "hbase-worker_kafka" {
  count        = "${var.n_hbase-worker_instances}"
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.hbase-worker_kafka.*.id[count.index]}"
  instance_id  = "${aws_instance.hbase-worker_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "fam-listener" {
  name        = "${var.env}-fam-listener"
  description = "Allows VPN to fam-listener app ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-fam-listener"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "fam-listener_allow_8000_from_vpn" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.fam-listener.id}"
}

resource "aws_instance" "fam-listener_instances" {
  count = "${var.n_fam-listener_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.fam-listener_instance_type}"
  subnet_id     = "${var.fam-listener_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.fam-listener.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.fam-listener_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("fam-listener%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "fam-listener,fam-backend,fam-web"
  }
}

resource "aws_ebs_volume" "fam-listener" {
  count             = "${var.n_fam-listener_instances}"
  availability_zone = "${aws_instance.fam-listener_instances.*.availability_zone[count.index]}"
  size              = "${var.fam-listener_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "fam-listener" {
  count        = "${var.n_fam-listener_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.fam-listener.*.id[count.index]}"
  instance_id  = "${aws_instance.fam-listener_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "faas-listener" {
  name        = "${var.env}-faas-listener"
  description = "Allows VPN to faas-listener app ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-faas-listener"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "faas-listener_allow_8000_from_vpn" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.faas-listener.id}"
}

resource "aws_instance" "faas-listener_instances" {
  count = "${var.n_faas-listener_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.faas-listener_instance_type}"
  subnet_id     = "${var.faas-listener_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.faas-listener.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.faas-listener_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("faas-listener%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "faas-listener"
  }
}

resource "aws_ebs_volume" "faas-listener" {
  count             = "${var.n_faas-listener_instances}"
  availability_zone = "${aws_instance.faas-listener_instances.*.availability_zone[count.index]}"
  size              = "${var.faas-listener_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "faas-listener" {
  count        = "${var.n_faas-listener_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.faas-listener.*.id[count.index]}"
  instance_id  = "${aws_instance.faas-listener_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_instance" "tusker_instances" {
  count = "${var.n_tusker_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.tusker_instance_type}"
  subnet_id     = "${var.tusker_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.backhaul-b.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
    "${aws_security_group.tusker.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.tusker_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("tusker%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "tusker"
  }
}

resource "aws_ebs_volume" "tusker" {
  count             = "${var.n_tusker_instances}"
  availability_zone = "${aws_instance.tusker_instances.*.availability_zone[count.index]}"
  size              = "${var.tusker_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "tusker" {
  count        = "${var.n_tusker_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.tusker.*.id[count.index]}"
  instance_id  = "${aws_instance.tusker_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "tusker" {
  count       = "${var.n_tusker_instances == 0 ? 0 : 1}"
  name        = "${var.env}-tusker"
  description = "Allows 8080 to VPN"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-tusker"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "tusker_allow_8080_from_vpn_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.tusker.id}"
}

resource "aws_instance" "cascade_instances" {
  count = "${var.n_cascade_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.cascade_instance_type}"
  subnet_id     = "${var.cascade_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.fronthaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.cascade_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "subnet_id"]
  }

  tags {
    Name       = "${var.env}.${format("cascade%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "cascade"
  }
}

resource "aws_eip" "cascade" {
  count    = "${var.cascade_subnet_placement == "public" ? var.n_cascade_instances : 0}"
  instance = "${aws_instance.cascade_instances.*.id[count.index]}"
  vpc      = true
}

resource "aws_ebs_volume" "cascade" {
  count             = "${var.n_cascade_instances}"
  availability_zone = "${aws_instance.cascade_instances.*.availability_zone[count.index]}"
  size              = "${var.cascade_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "cascade" {
  count        = "${var.n_cascade_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.cascade.*.id[count.index]}"
  instance_id  = "${aws_instance.cascade_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_instance" "analytics-server_instances" {
  count = "${var.n_analytics-server_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.analytics-server_instance_type}"
  subnet_id     = "${var.analytics-server_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.analytics-server_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("analytics-server%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "analytics-server,listener-server"
  }
}

resource "aws_ebs_volume" "analytics-server" {
  count             = "${var.n_analytics-server_instances}"
  availability_zone = "${aws_instance.analytics-server_instances.*.availability_zone[count.index]}"
  size              = "${var.analytics-server_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "analytics-server" {
  count        = "${var.n_analytics-server_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.analytics-server.*.id[count.index]}"
  instance_id  = "${aws_instance.analytics-server_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "openadr2b" {
  count       = "${var.n_openadr2b_instances == 0 ? 0 : 1}"
  name        = "${var.env}-openadr2b"
  description = "Allows HTTPS to all"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-openadr2b"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "openadr2b_allow_https_from_all" {
  count             = "${var.n_openadr2b_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.openadr2b.id}"
}

resource "aws_instance" "openadr2b_instances" {
  count = "${var.n_openadr2b_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.openadr2b_instance_type}"
  subnet_id     = "${var.openadr2b_subnet_placement == "public" ? aws_subnet.internet-b.id : aws_subnet.fronthaul-b.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.openadr2b.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.openadr2b_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "subnet_id"]
  }

  tags {
    Name       = "${var.env}.${format("openadr2b%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "openadr2b"
  }
}

resource "aws_eip" "openadr2b" {
  count    = "${var.openadr2b_subnet_placement == "public" ? var.n_openadr2b_instances : 0}"
  instance = "${aws_instance.openadr2b_instances.*.id[count.index]}"
  vpc      = true
}

resource "aws_ebs_volume" "openadr2b" {
  count             = "${var.n_openadr2b_instances}"
  availability_zone = "${aws_instance.openadr2b_instances.*.availability_zone[count.index]}"
  size              = "${var.openadr2b_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "openadr2b" {
  count        = "${var.n_openadr2b_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.openadr2b.*.id[count.index]}"
  instance_id  = "${aws_instance.openadr2b_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_security_group" "proxy" {
  count       = "${var.n_proxy_instances == 0 ? 0 : 1}"
  name        = "${var.env}-proxy"
  description = "Allows proxy ELB to HTTPS"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-proxy"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "proxy_allow_https_from_all" {
  count             = "${var.n_proxy_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.proxy.id}"
}

resource "aws_instance" "proxy_instances" {
  count = "${var.n_proxy_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.proxy_instance_type}"
  subnet_id     = "${var.proxy_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.fronthaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.proxy.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.proxy_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("proxy%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "proxy"
  }
}

resource "aws_ebs_volume" "proxy" {
  count             = "${var.n_proxy_instances}"
  availability_zone = "${aws_instance.proxy_instances.*.availability_zone[count.index]}"
  size              = "${var.proxy_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "proxy" {
  count        = "${var.n_proxy_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.proxy.*.id[count.index]}"
  instance_id  = "${aws_instance.proxy_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_eip" "proxy" {
  instance = "${aws_instance.proxy_instances.*.id[count.index]}"
  vpc      = true
}

resource "aws_security_group" "grafana_elb" {
  count       = "${var.n_grafana_instances == 0 ? 0 : 1}"
  name        = "${var.env}-grafana-elb"
  description = "Allows VPN to grafana elb app ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-grafana-elb"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "grafana_elb_allow_3000_from_vpn" {
  count             = "${var.n_grafana_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.grafana_elb.id}"
}

resource "aws_alb" "grafana" {
  count    = "${var.n_grafana_instances == 0 ? 0 : 1}"
  name     = "${var.env}-grafana"
  internal = true

  security_groups = [
    "${aws_security_group.grafana_elb.id}",
    "${aws_security_group.fronthaul.id}",
  ]

  subnets = [
    "${aws_subnet.fronthaul-a.id}",
    "${aws_subnet.fronthaul-b.id}",
  ]

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_alb_listener" "grafana" {
  count             = "${var.n_grafana_instances == 0 ? 0 : 1}"
  load_balancer_arn = "${aws_alb.grafana.arn}"
  port              = "3000"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.external_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.grafana.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "grafana" {
  count    = "${var.n_grafana_instances == 0 ? 0 : 1}"
  name     = "${var.env}-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  health_check {
    path    = "/login"
    matcher = 200
  }
}

resource "aws_alb_target_group_attachment" "grafana" {
  count            = "${var.n_grafana_instances}"
  target_group_arn = "${aws_alb_target_group.grafana.arn}"
  target_id        = "${aws_instance.grafana_instances.*.id[count.index]}"
  port             = 3000
}

resource "aws_security_group" "grafana" {
  count       = "${var.n_grafana_instances == 0 ? 0 : 1}"
  name        = "${var.env}-grafana"
  description = "Allows VPN to grafana app ports"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name       = "${var.env}-grafana"
    stack_name = "${var.env}"
  }
}

resource "aws_security_group_rule" "grafana_allow_3000_from_vpn" {
  count             = "${var.n_grafana_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "grafana_allow_3000_from_elb" {
  count                    = "${var.n_grafana_instances == 0 ? 0 : 1}"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.grafana_elb.id}"
  security_group_id        = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "grafana_allow_8086_from_vpn" {
  count             = "${var.n_grafana_instances == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 8086
  to_port           = 8086
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.11/32"]
  security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_instance" "grafana_instances" {
  count = "${var.n_grafana_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.grafana_instance_type}"
  subnet_id     = "${aws_subnet.fronthaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.fronthaul.id}",
    "${aws_security_group.grafana.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.grafana_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("grafana%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "grafana"
  }
}

resource "aws_ebs_volume" "grafana" {
  count             = "${var.n_grafana_instances}"
  availability_zone = "${aws_instance.grafana_instances.*.availability_zone[count.index]}"
  size              = "${var.grafana_ag_volume_size}"
  type              = "gp2"

  tags {
    stack_name = "${var.env}"
  }
}

resource "aws_volume_attachment" "grafana" {
  count        = "${var.n_grafana_instances}"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.grafana.*.id[count.index]}"
  instance_id  = "${aws_instance.grafana_instances.*.id[count.index]}"
  skip_destroy = true
}

resource "aws_instance" "k8s_proxy_instances" {
  count = "${var.n_k8s_proxy_instances}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.k8s_proxy_instance_type}"
  subnet_id     = "${var.k8s_proxy_subnet_placement == "public" ? aws_subnet.internet-a.id : aws_subnet.backhaul-a.id}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ops.id}",
    "${aws_security_group.backhaul.id}",
  ]

  volume_tags {
    stack_name = "${var.env}"
  }

  root_block_device {
    volume_size = "${var.k8s_proxy_root_volume_size}"
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name       = "${var.env}.${format("kubernetes-proxy%02d.autogrid.aws", count.index + 1)}"
    backup     = "true"
    stack_name = "${var.env}"
    role       = "kubernetes-proxy"
  }
}
