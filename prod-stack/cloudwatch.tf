resource "aws_cloudwatch_metric_alarm" "main_free_storage" {
  alarm_name                = "${var.env}_freestorage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "40000000000" # TODO this should probably just be a percentage of the full disk
  alarm_description         = "This metric monitors free disk space"
  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.main.id}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "main_cpu" {
  alarm_name                = "${var.env}_cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "This metric monitors CPU utilization"
  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.main.id}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "ceep_free_storage" {
  alarm_name                = "${var.env}-ceep_freestorage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "40000000000"
  alarm_description         = "This metric monitors free disk space"
  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.ceep.id}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "ceep_cpu" {
  alarm_name                = "${var.env}-ceep_cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "This metric monitors CPU utilization"
  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.ceep.id}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "main_replica_lag" {
  alarm_name                = "${var.env}-replica_replicalag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ReplicaLag"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "300"
  alarm_description         = "This metric monitors Replica Lag"
  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.main-replica.id}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "pheme_elb_health" {
  alarm_name                = "${var.env}-pheme-health"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "3"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "${var.n_pheme_instances}"
  alarm_description         = "Alarm when healthy instance count is less than number of instances assigned to TargetGroup"
  dimensions {
    LoadBalancer = "${aws_alb.pheme.arn_suffix}"
    TargetGroup  = "${aws_alb_target_group.pheme.arn_suffix}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}

resource "aws_cloudwatch_metric_alarm" "ceep_elb_health" {
  alarm_name                = "${var.env}-ceep-health"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "3"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "${var.n_ceep_instances}"
  alarm_description         = "Alarm when healthy instance count is less than number of instances assigned to TargetGroup"
  dimensions {
    LoadBalancer = "${aws_alb.ceep.arn_suffix}"
    TargetGroup  = "${aws_alb_target_group.ceep.arn_suffix}"
  }
  alarm_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
  ok_actions = [
    "arn:aws:sns:${var.region}:948569044292:PagerDuty_ProdOps"
  ]
}
