
resource "aws_lambda_function" "LambdaWAFCustomResourceFunction" {
    depends_on = ["aws_s3_bucket_object.CustomResourceZip"]
    function_name = "${var.customer}-LambdaWAFCustomResourceFunction-${element(split("-",uuid()),0)}"
    description = "This lambda function configures the Web ACL rules based on the features enabled in the CloudFormation template. Parameters: yes"
    role = "${aws_iam_role.LambdaRoleCustomResource.arn}"
    handler = "custom-resource.lambda_handler"
    s3_bucket = "${var.customer}-waflambdafiles"
    s3_key = "custom-resource.zip"
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
            SendAnonymousUsageData = "${var.SendAnonymousUsageData}"
        }
    }
}

