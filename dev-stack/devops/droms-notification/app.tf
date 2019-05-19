provider "aws" {
  region     = "${var.region}"
}

data "aws_instances" "ec2" {
  filter {
    name = "tag:role"
    values = ["${var.instance_role}"]
  }

  filter {
    name = "tag:stack_name"
    values = ["${var.env}"]
  }
}

resource "aws_ami_from_instance" "ami" {
  name               = "${var.ami_name}"
  source_instance_id = "${element(split(",", data.aws_instances.ec2.ids[count.index]),0)}"
}



data "aws_security_group" "ec2_sg1" {
  filter {
    name = "tag:stack_name"
    values = ["${var.sg_stack_name}"]
  }

  filter {
    name = "tag:Name"
    values = ["${var.sg_name1}"]
  }
}

data "aws_security_group" "ec2_sg2" {
  filter {
    name = "tag:stack_name"
    values = ["${var.sg_stack_name}"]
  }

  filter {
    name = "tag:Name"
    values = ["${var.sg_name2}"]
  }
}

resource "aws_launch_configuration" "lc" {
  count         = 1
  name          = "${var.lc_name}"
  image_id      = "${aws_ami_from_instance.ami.id}"
  instance_type = "${var.instance_type}"
  security_groups = [ "${data.aws_security_group.ec2_sg1.id}" , "${data.aws_security_group.ec2_sg2.id}" ]
}


data "aws_vpc" "vpc" {
  filter {
    name   = "tag:stack_name"
    values = ["${var.vpc_stack_name}"]
  }
}


data "aws_subnet_ids" "fronthaul" {
  vpc_id = "${data.aws_vpc.vpc.id}" 
   filter {
    name   = "tag:stack_name"
    values = ["${var.vpc_stack_name}"]
  }
   filter {
    name   = "tag:Name"
    values = ["${var.subnet_name}"]
  }
}

data "aws_subnet" "subnet" {
  count = "${length(data.aws_subnet_ids.fronthaul.ids)}"
  id    = "${data.aws_subnet_ids.fronthaul.ids[count.index]}"
}


resource "aws_autoscaling_group" "asg" {
  count                = 1
  name                 = "${var.asg_name}"
  launch_configuration = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier  = ["${data.aws_subnet.subnet.*.id}"]

  min_size              = "${var.min}"
  max_size              = "${var.max}"
  protect_from_scale_in = false
  force_delete          = true

  suspended_processes = [
    "ReplaceUnhealthy",
  ]
}
# scale up alarm
resource "aws_autoscaling_policy" "asp-scaleup" {
	name = "${var.asp_scaleup_name}"
	autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "10"
	cooldown = "300"
	policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "alarm_up" {
	alarm_name = "${var.alarm_name_scaleup}"
	alarm_description = "${var.alarm_name_scaleup}"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = "1"
	metric_name = "${var.metrics_name}"
	namespace = "Custom"
	period = "60"
	statistic = "Average"
	threshold = "300"
	dimensions = "${var.dimensions_name}"
  actions_enabled = true
  alarm_actions = ["${aws_autoscaling_policy.asp-scaleup.arn}"]
}


# scale down alarm
resource "aws_autoscaling_policy" "asp-scaledown" {
	name = "${var.asp_scaledown_name}"
	autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "-10"
	cooldown = "300"
	policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "alarm_down" {
	alarm_name = "${var.alarm_name_scaledown}"
	alarm_description = "${var.alarm_name_scaledown}"
	comparison_operator = "LessThanOrEqualToThreshold"
	evaluation_periods = "1"
	metric_name = "${var.metrics_name}"
	namespace = "Custom"
	period = "300"
	statistic = "Average"
	threshold = "50"
	dimensions = "${var.dimensions_name}"
	actions_enabled = true
	alarm_actions = ["${aws_autoscaling_policy.asp-scaledown.arn}"]
}

