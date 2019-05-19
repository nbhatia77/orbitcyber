
resource "aws_iam_role" "LambdaRoleBadBot" {
    name = "${var.customer}-LambdaRoleBadBot"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
    path = "/"
}
resource "aws_iam_role_policy" "LambdaRoleBadBotWAFGetChangeToken" {
    name = "${var.customer}-LambdaRoleBadBotWAFGetChangeToken"
    role = "${aws_iam_role.LambdaRoleBadBot.id}"
    policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf:GetChangeToken"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleBadBotWAFGetAndUpdateIPSet" {
    name = "${var.customer}-LambdaRoleBadBotWAFGetAndUpdateIPSet"
    role = "${aws_iam_role.LambdaRoleBadBot.id}"
    policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf:GetIPSet",
        "waf:UpdateIPSet"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.WAFBadBotSet.id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleBadBotLogsAccess" {
    name = "${var.customer}-LambdaRoleBadBotLogsAccess"
    role = "${aws_iam_role.LambdaRoleBadBot.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleBadBotCloudWatchAccess" {
    name = "${var.customer}-LambdaRoleBadBotCloudWatchAccess"
    role = "${aws_iam_role.LambdaRoleBadBot.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "cloudwatch:GetMetricStatistics",
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
