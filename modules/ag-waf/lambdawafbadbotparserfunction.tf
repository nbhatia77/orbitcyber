
resource "aws_lambda_function" "LambdaWAFBadBotParserFunction" {
    depends_on = ["aws_s3_bucket_object.AccessHandlerZip"]
    function_name = "${var.customer}-LambdaWAFBadBotParserFunction-${element(split("-",uuid()),0)}"
    description = "This lambda function will intercepts and inspects trap endpoint requests to extract its IP address, and then add it to an AWS WAF block list."
    role = "${aws_iam_role.LambdaRoleBadBot.arn}"
    handler = "access-handler.lambda_handler"
    s3_bucket = "${var.customer}-waflambdafiles"
    s3_key = "access-handler.zip"
    runtime = "python2.7"
    memory_size = "128"
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
            WAFBadBotSet = "${aws_waf_ipset.WAFBadBotSet.id}"
            SendAnonymousUsageData = "${var.SendAnonymousUsageData}"
            UUID = "${uuid()}"
        }
    }
}
