
resource "aws_iam_role" "LambdaRoleReputationListsParser" {
    name = "${var.customer}-LambdaRoleReputationListsParser"
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
resource "aws_iam_role_policy" "LambdaRoleReputationListsParserCloudWatchLogs" {
    name = "${var.customer}-LambdaRoleReputationListsParserCloudWatchLogs"
    role = "${aws_iam_role.LambdaRoleReputationListsParser.id}"
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
resource "aws_iam_role_policy" "LambdaRoleReputationListsParserWAFGetChangeToken" {
    name = "${var.customer}-LambdaRoleReputationListsParserWAFGetChangeToken"
    role = "${aws_iam_role.LambdaRoleReputationListsParser.id}"
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
resource "aws_iam_role_policy" "LambdaRoleReputationListsParserWAFGetAndUpdateIPSet" {
    name = "${var.customer}-LambdaRoleReputationListsParserWAFGetAndUpdateIPSet"
    role = "${aws_iam_role.LambdaRoleReputationListsParser.id}"
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
        "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.WAFReputationListsSet1.id}",
        "arn:aws:waf::${data.aws_caller_identity.current.account_id}:ipset/${aws_waf_ipset.WAFReputationListsSet2.id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleReputationListsParserCloudWatchAccess" {
    name = "${var.customer}-LambdaRoleReputationListsParserCloudWatchAccess"
    role = "${aws_iam_role.LambdaRoleReputationListsParser.id}"
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
