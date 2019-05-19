
resource "aws_iam_role" "LambdaRoleLogParser" {
    name = "${var.customer}-LambdaRoleLogParser"
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
resource "aws_iam_role_policy" "LambdaRoleLogParserS3Access" {
    name = "${var.customer}-LambdaRoleLogParserS3Access"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.CloudFrontAccessLogBucket}/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleLogParserS3AccessPut" {
    name = "${var.customer}-LambdaRoleLogParserS3AccessPut"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.CloudFrontAccessLogBucket}/aws-waf-security-automations-current-blocked-ips.json"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleLogParserWAFGetChangeToken" {
    name = "${var.customer}-LambdaRoleLogParserWAFGetChangeToken"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
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
resource "aws_iam_role_policy" "LambdaRoleLogParserWAFGetAndUpdateIPSet" {
    name = "${var.customer}-LambdaRoleLogParserWAFGetAndUpdateIPSet"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
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
          "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.WAFBlacklistSet.id}",
          "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.WAFAutoBlockSet.id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleLogParserLogsAccess" {
    name = "${var.customer}-LambdaRoleLogParserLogsAccess"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
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
resource "aws_iam_role_policy" "LambdaRoleLogParserCloudWatchAccess" {
    name = "${var.customer}-LambdaRoleLogParserCloudWatchAccess"
    role = "${aws_iam_role.LambdaRoleLogParser.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:GetMetricStatistics"
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
