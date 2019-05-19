
resource "aws_lambda_function" "LambdaWAFLogParserFunction" {
    depends_on = ["aws_s3_bucket_object.LogParserZip"]
    function_name = "${var.customer}-LambdaWAFLogParserFunction-${element(split("-",uuid()),0)}"
    description = "This function parses CloudFront access logs to identify suspicious behavior, such as an abnormal amount of requests or errors. It then blocks those IP addresses for a customer-defined period of time."
    role = "${aws_iam_role.LambdaRoleLogParser.arn}"
    handler = "log-parser.lambda_handler"
    #s3_bucket = "solutions-${var.aws_region}"
    #s3_key = "aws-waf-security-automations/v1/log-parser.zip"
    s3_bucket = "${var.customer}-waflambdafiles"
    s3_key = "log-parser.zip"
    runtime = "python2.7"
    memory_size = "512"
    timeout = "300"
    environment {
        variables = {
            CloudFrontAccessLogBucket = "${var.CloudFrontAccessLogBucket}"
            ActivateBadBotProtectionParam = "${var.ActivateBadBotProtectionParam}"
            ActivateHttpFloodProtectionParam = "${var.ActivateHttpFloodProtectionParam}"
            ActivateReputationListsProtectionParam = "${var.ActivateReputationListsProtectionParam}"
            ActivateScansProbesProtectionParam = "${var.ActivateScansProbesProtectionParam}"
            CrossSiteScriptingProtectionParam = "${var.CrossSiteScriptingProtectionParam}"
            SqlInjectionProtectionParam = "${var.SqlInjectionProtectionParam}"
            ErrorThreshold = "${var.ErrorThreshold}"
            RequestThreshold = "${var.RequestThreshold}"
            WAFBlockPeriod = "${var.WAFBlockPeriod}"
            BlacklistIPSetID = "${aws_waf_ipset.WAFBlacklistSet.id}"
            AutoBlockIPSetID = "${aws_waf_ipset.WAFAutoBlockSet.id}"
            SendAnonymousUsageData = "${var.SendAnonymousUsageData}"
            UUID = "${uuid()}"
        }
    }
}
