
resource "aws_iam_role" "LambdaRoleCustomResource" {
    name = "${var.customer}-LambdaRoleCustomResource"
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
resource "aws_iam_role_policy" "LambdaRoleCustomResourceS3Access" {
    name = "${var.customer}-LambdaRoleCustomResourceS3Access"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:CreateBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketNotification",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutBucketNotification"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.CloudFrontAccessLogBucket}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleCustomResourceLambdaAccess" {
    name = "${var.customer}-LambdaRoleCustomResourceLambdaAccess"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFAccess" {
    name = "${var.customer}-LambdaRoleCustomResourceWAFAccess"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "waf:GetWebACL",
        "waf:UpdateWebACL"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:waf::${data.aws_caller_identity.current.account_id}:webacl/${aws_waf_web_acl.WAFWebACL.id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFRuleAccess" {
    name = "${var.customer}-LambdaRoleCustomResourceWAFRuleAccess"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "waf:GetRule"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:waf::${data.aws_caller_identity.current.account_id}:rule/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFGetChangeToken" {
    name = "${var.customer}-LambdaRoleCustomResourceWAFGetChangeToken"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
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
resource "aws_iam_role_policy" "LambdaRoleCustomResourceLogsAccess" {
    name = "${var.customer}-LambdaRoleCustomResourceLogsAccess"
    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
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
