
output "rds_pass" {
    value = "${aws_ssm_parameter.rds_password.value}"
}
