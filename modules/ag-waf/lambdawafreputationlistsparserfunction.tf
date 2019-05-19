
resource "aws_lambda_function" "LambdaWAFReputationListsParserFunction" {
    depends_on = ["aws_s3_bucket_object.ReputationListsParserZip"]
    function_name = "${var.customer}-LambdaWAFReputationListsParserFunction-${element(split("-",uuid()),0)}"
    description = "This lambda function checks third-party IP reputation lists hourly for new IP ranges to block. These lists include the Spamhaus Dont Route Or Peer (DROP) and Extended Drop (EDROP) lists, the Proofpoint Emerging Threats IP list, and the Tor exit node list."
    role = "${aws_iam_role.LambdaRoleReputationListsParser.arn}"
    handler = "reputation-lists-parser.handler"
    s3_bucket = "${var.customer}-waflambdafiles"
    s3_key = "reputation-lists-parser.zip"
    runtime = "nodejs8.10"
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
            SendAnonymousUsageData = "${var.SendAnonymousUsageData}"
        }
    }
}
